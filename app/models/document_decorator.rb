Document.class_eval do
  safe_attributes :notifications_disabled

  private

  def send_notification
    return if self.notifications_disabled?

    if Setting.notified_events.include?('document_added')
      Mailer.deliver_document_added(self, User.current)
    end
  end
end
