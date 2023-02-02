WelcomeController.class_eval do
  def index
    @news     = News.latest User.current
    @projects = Project.latest User.current
  end
end
