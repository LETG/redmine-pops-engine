News.class_eval do
  safe_attributes :notifications_disabled

  private

  def send_notification
    return if self.notifications_disabled?

    if Setting.notified_events.include?('news_added')
      Mailer.deliver_news_added(self)
    end
  end
end