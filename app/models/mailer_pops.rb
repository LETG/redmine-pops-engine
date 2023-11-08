require 'active_support/concern'

module MailerPops
  extend ActiveSupport::Concern
  
  included do
    def mail(headers = {}, &block)
      headers[:subject] = notification_subject(headers[:subject]) if headers && headers[:subject].present?
      super(headers, &block)
    end

    private
      def notification_project
        @project   = (@issue.project rescue nil)                       if @issue
        @project ||= (@document.project rescue nil)                    if @project
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

