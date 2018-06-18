ProjectsController.class_eval do
  before_filter :permit_parameters, only: [ :create, :update ]
  
  self.main_menu = false

  protected
    def permit_parameters
      params.permit!
    end
end
