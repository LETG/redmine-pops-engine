# frozen_string_literal: true

require 'pops_engine/mail_parser'

class ResourcesController < ApplicationController
  # Création d'une ressource à partir d'un mail reçu (annonce ou document).
  # Le paramètre :email doit contenir le contenu complet du mail sous forme de string.
  def create
    valid = true
    mail = Mail.new(params[:email])

    # Identification du compte Redmine correspondant à l'expéditeur du mail
    author = EmailAddress.find_by(address: Array.wrap(mail.from).first.strip)&.user

    # Extraction des identifiants des projets concernés à partir des adresses mail destinataires
    project_identifiers = Array.wrap(mail.to).reduce([]) do |arr, address|
      identifier = address.split('@').first.strip
      arr << identifier unless arr.include?(identifier)
    end

    # Récupération des projets correspondants aux identifiants concernés
    projects = Project.where(identifier: project_identifiers)

    unless projects.any?
      valid = false
      error_code = :not_found
      error_msg = "Aucun projet correspondant n'a été trouvé"
    end

    if valid
      document_categories = DocumentCategory.all
      document_tags = ActsAsTaggableOn::Tag.all

      # Valeurs par défaut des champs d'une ressource
      resource_data = {
        common: { # Champs communs (annonces et documents)
          title: nil,
          notifications_disabled: false,
          notify_users_in_parent_projects: false,
          description: nil
        },
        news: { # Champs spécifiques d'une annonce
          visible_in_timeline: false,
          private: false,
          summary: nil,
          announcement_date: mail.date.beginning_of_day,
          author: author
        },
        document: { # Champs spécifiques d'un document
          visible_in_timeline: true,
          visible_to_public: true,
          category: document_categories.find { |dc| dc.name.downcase == 'gestion de projet' },
          tag_list: document_tags.find { |dt| dt.name.downcase == 'document' }&.name,
          created_date: mail.date.beginning_of_day,
          url_to: nil
        }
      }

      # Fichiers de la ressource (pièces jointes du mail)
      filenames = []

      # Parsing du sujet du mail
      subject_parts = mail.subject.match(/\[(.*)\](.*)/).captures.map(&:strip)

      # Détermination du type de ressource (annonce ou document)
      resource_type =
        case subject_parts.first.downcase
        when 'annonce'
          :news
        when 'document'
          :document
        end

      if resource_type.blank?
        valid = false
        error_code = :unprocessable_entity
        error_msg = 'Type de ressource non renseigné'
      end
    end

    if valid
      # Détermination du titre de la ressource
      resource_data[:common][:title] = subject_parts[1..].join(' ')

      # Récupération du contenu HTML du mail
      mail_html = MailParser.get_parsed_html(mail)

      # Extractions des données de la ressource à partir du corps HTML du mail
      mail_html
        .xpath('//text()')
        .map { |x| x.text.gsub(160.chr('UTF-8'), '').strip }
        .reject { |x| x == '' }
        .each do |line|
          case line
          when /--.*frise.*:/
            # Parsing de l'affichage de la ressource dans la timeline
            if resource_type == :news
              resource_data[:news][:visible_in_timeline] = line.split(':').last.strip.downcase == 'oui'
            else
              resource_data[:document][:visible_in_timeline] = line.split(':').last.strip.downcase == 'oui'
            end
          when /--.*notifications?.*:/
            # Parsing de l'activation ou non des notifications
            resource_data[:common][:notifications_disabled] = line.split(':').last.strip.downcase == 'non'
          when /--.*acc[eè]s.*:/
            # Parsing de la restriction d'accès
            if resource_type == :news
              resource_data[:news][:private] =
                %w[privé prive].include?(line.split(':').last.strip.downcase)
            else
              resource_data[:document][:visible_to_public] =
                !%w[privé prive].include?(line.split(':').last.strip.downcase)
            end
          when /--.*r[eé]sum[eé].*:/
            # Parsing du résumé (annonce seulement)
            resource_data[:news][:summary] = line.split(':').last.strip
          when /--.*date.*:/
            # Parsing de la date de programmation (annonce) ou de création (document)
            parsed_date = Date.strptime(line.split(':').last.strip, '%d/%m/%Y') rescue nil

            if resource_type == :news
              resource_data[:news][:announcement_date] = parsed_date
            else
              resource_data[:document][:created_date] = parsed_date
            end
          when /--.*cat[eé]gorie.*:/
            # Parsing de la catégorie (document seulement)
            resource_data[:document][:category] =
              document_categories.find { |dc| dc.name.downcase == line.split(':').last.strip.downcase }
          when /--.*tag.*:/
            # Parsing du tag (document seulement)
            resource_data[:document][:tag_list] =
              document_tags.find { |dt| dt.name.downcase == line.split(':').last.strip.downcase }&.name
          when /--.*url.*:/
            # Parsing de l'url (document seulement)
            resource_data[:document][:url_to] = line.split(':').last.strip
          else
            # Autre contenu textuel => ajout à la description
            resource_data[:common][:description] ||= []
            resource_data[:common][:description] << line unless line.starts_with?('--')
          end
        end

      # Jointure des textes de la description avec des retours à la ligne
      if resource_data[:common][:description].is_a?(Array)
        resource_data[:common][:description] = resource_data[:common][:description].join("\r\n")
      end

      # Écriture des fichiers de la ressource dans un répertoire temporaire à partir des pièces jointes du mail
      mail.attachments.each do |mail_attachment|
        filename = Rails.root.join("tmp/#{mail_attachment.filename}")
        File.open(filename, 'wb') { |f| f.write(mail_attachment.decoded) }
        filenames << filename
      end

      # Création de la ressource dans chaque projet concerné
      projects.each do |project|
        if author.present?
          # Passage au projet suivant si le compte Redmine de l'auteur n'a pas les droits nécessaires
          project_roles = author.roles_for_project(project).map(&:permissions).flatten.uniq
          next if resource_type == :news && !project_roles.include?(:manage_news)
          next if resource_type == :document && !project_roles.include?(:add_documents)
        end

        resource =
          if resource_type == :news
            project.news.create!(resource_data[:common].merge(resource_data[:news]))
          else
            project.documents.create!(resource_data[:common].merge(resource_data[:document]))
          end

        # Ajout des fichiers dans la ressource
        filenames.each do |filename|
          next unless File.exist?(filename)

          resource.attachments.create!(
            file: File.new(filename),
            filename: filename,
            author_id: (author.present? ? author.id : 0)
          )
        end
      end

      # Suppression des fichiers temporaires
      filenames.each { |filename| File.delete(filename) if File.exist?(filename) }
    end

    if valid
      response = { message: 'La ressource a été crée' }

      respond_to do |format|
        format.json { render json: response, status: :ok }
        format.xml { render xml: response, status: :ok }
      end
    else
      response = { error: error_msg }

      respond_to do |format|
        format.json { render json: response, status: error_code }
        format.xml { render xml: response, status: error_code }
      end
    end
  end
end
