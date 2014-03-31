PopsRedmineEngine::Engine.routes.draw do
  RedmineApp::Application.routes.draw do
    resources :projects do
      member do
        get 'timeline'
      end
    end
  end
end
