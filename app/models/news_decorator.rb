News.class_eval do
  safe_attributes :notifications_disabled
  safe_attributes :notify_users_in_parent_projects

  def notified_users
    projects = Array.wrap(project)

    if self.notify_users_in_parent_projects
      p_proj = project.parent

      while p_proj
        projects << p_proj
        p_proj = p_proj.parent
      end
    end

    users = projects.inject([]) do |arr, project|
      project.users.each do |user|
        arr << user if user.notify_about?(self) && user.allowed_to?(:view_news, project) && !arr.include?(user)
      end

      arr
    end

    users
  end

  def is_private?
    self.private? || !self.project.is_public?
  end

  private
    def send_notification
      return if self.notifications_disabled?

      if Setting.notified_events.include?('news_added')
        Mailer.deliver_news_added(self)
      end
    end
end
