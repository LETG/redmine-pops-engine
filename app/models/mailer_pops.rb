require 'active_support/concern'

module MailerPops
  extend ActiveSupport::Concern
  
  included do
    def mail(headers={}, &block)
      headers[:subject] = notification_subject(headers[:subject]) if headers && headers[:subject].present?

      # Add a display name to the From field if Setting.mail_from does not
      # include it
      begin
        mail_from = Mail::Address.new(Setting.mail_from)
        if mail_from.display_name.blank? && mail_from.comments.blank?
          mail_from.display_name =
            @author&.logged? ? @author.name : Setting.app_title
        end
        from = mail_from.format
        list_id = "<#{mail_from.address.to_s.tr('@', '.')}>"
      rescue Mail::Field::IncompleteParseError
        # Use Setting.mail_from as it is if Mail::Address cannot parse it
        # (probably the emission address is not RFC compliant)
        from = Setting.mail_from.to_s
        list_id = "<#{from.tr('@', '.')}>"
      end

      headers.reverse_merge! 'X-Mailer' => 'Redmine',
              'X-Redmine-Host' => Setting.host_name,
              'X-Redmine-Site' => Setting.app_title,
              'X-Auto-Response-Suppress' => 'All',
              'Auto-Submitted' => 'auto-generated',
              'From' => from,
              'List-Id' => list_id

      # Replaces users with their email addresses
      [:to, :cc, :bcc].each do |key|
        if headers[key].present?
          headers[key] = self.class.email_addresses(headers[key])
        end
      end

      # Removes the author from the recipients and cc
      # if the author does not want to receive notifications
      # about what the author do
      if @author&.logged? && @author.pref.no_self_notified
        addresses = @author.mails
        headers[:to] -= addresses if headers[:to].is_a?(Array)
        headers[:cc] -= addresses if headers[:cc].is_a?(Array)
      end

      if @author&.logged?
        redmine_headers 'Sender' => @author.login
      end

      if @message_id_object
        headers[:message_id] = "<#{self.class.message_id_for(@message_id_object, @user)}>"
      end
      if @references_objects
        headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o, @user)}>"}.join(' ')
      end

      if block_given?
        super headers, &block
      else
        super headers do |format|
          format.text
          format.html unless Setting.plain_text_mail?
        end
      end
    end
    
    private
      def notification_project
        @project   = (@issue.project rescue nil)                       if @issue
        @project ||= (@document.project rescue nil)                    if @document
        @project ||= (@attachments.first.container.project rescue nil) if @attachments
        @project ||= (@news.project rescue nil)                        if @news
        @project ||= (@message.board.project rescue nil)               if @message
        @project
      end

      def notification_subject(subject)
        return subject unless notification_project && notification_project.parent
        return subject unless subject.match(/^\[(#{notification_project.name})([^\]]*)\](.*)$/)

        project       = notification_project
        project_names = []

        while project
          project_names.prepend project.name
          project = project.parent
        end

        return subject.gsub(/^\[(#{notification_project.name})([^\]]*)\](.*)$/, '[' + project_names.join(':') + '\2]\3')
      end
  end
end

Mailer.send(:include, MailerPops)

