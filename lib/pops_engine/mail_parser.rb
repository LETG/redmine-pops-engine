# frozen_string_literal: true

require 'mail'
require 'nokogiri'

module MailParser
  extend self

  def get_mail_parts(mail)
    if mail.multipart?
      html_part = mail.html_part
      text_part = mail.text_part

      # Quand il y a plusieurs text parts dont certaines sont vides
      if text_part && text_part.decoded.blank?
        text_part = mail.parts.find do |p|
          !p.content_type.nil? && p.content_type['text/plain'] && p.decoded.present?
        end
      end
    else
      html_part = mail.body unless mail&.content_type&.match(%r{text/plain})
      text_part = mail.body
    end

    [html_part, text_part]
  end

  def get_parsed_html(mail)
    html_part, = get_mail_parts(mail)

    unless html_part
      $log.debug 'Pas de part HTML'
      return nil
    end

    Nokogiri::HTML(html_part.decoded.gsub(/\s+/, ' '))
  end
end
