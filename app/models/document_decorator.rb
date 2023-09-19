Document.class_eval do
  safe_attributes :notifications_disabled

  def private?
    !self.visible_to_public? || !self.project.is_public?
  end

  private

  def send_notification
    return if self.notifications_disabled?

    if Setting.notified_events.include?('document_added')
      Mailer.deliver_document_added(self, User.current)
    end
  end
end
