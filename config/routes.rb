PopsRedmineEngine::Engine.routes.draw do
  RedmineApp::Application.routes.draw do
    get 'searchHal', to: 'hal#searchHal'
    get 'searchArticleOnHal', to: 'hal#searchArticleOnHal'
    resources :projects do
      member do
        get 'timeline'
      end
    end
  end
end
