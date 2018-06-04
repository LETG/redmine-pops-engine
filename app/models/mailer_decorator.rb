Mailer.class_eval do
  def mail(headers={}, &block)
    headers.reverse_merge! 'X-Mailer' => 'Redmine',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title,
            'X-Auto-Response-Suppress' => 'All',
            'Auto-Submitted' => 'auto-generated',
            'From' => Setting.mail_from,
            'List-Id' => "<#{Setting.mail_from.to_s.gsub('@', '.')}>"

    if ApplicationConfig.debug_mail
      headers[:to]  = ApplicationConfig.mail_recipients
      headers[:cc]  = []
      headers[:bcc] = []
    else
      # Replaces users with their email addresses
      [:to, :cc, :bcc].each do |key|
        if headers[key].present?
          headers[key] = self.class.email_addresses(headers[key])
        end
      end
    end

    # Removes the author from the recipients and cc
    # if the author does not want to receive notifications
    # about what the author do
    if @author && @author.logged? && @author.pref.no_self_notified
      addresses = @author.mails
      headers[:to] -= addresses if headers[:to].is_a?(Array)
      headers[:cc] -= addresses if headers[:cc].is_a?(Array)
    end

    if @author && @author.logged?
      redmine_headers 'Sender' => @author.login
    end

    # Blind carbon copy recipients
    if Setting.bcc_recipients?
      headers[:bcc] = [headers[:to], headers[:cc]].flatten.uniq.reject(&:blank?)
      headers[:to] = nil
      headers[:cc] = nil
    end

    if @message_id_object
      headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
    end
    if @references_objects
      headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o)}>"}.join(' ')
    end

    m = if block_given?
      super headers, &block
    else
      super headers do |format|
        format.text
        format.html unless Setting.plain_text_mail?
      end
    end
    set_language_if_valid @initial_language

    m
  end
end