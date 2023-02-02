# require 'redmine'

module PopsEngine
  module ProjectsControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        before_filter :permit_parameters, only: [ :create, :update ]

        self.main_menu = false

        protected
          def permit_parameters
            params.permit!
          end
      end
    end
  end
end

# ProjectsController.send(:include, PopsEngine::ProjectsControllerPatch)