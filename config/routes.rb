PopsRedmineEngine::Engine.routes.draw do
  RedmineApp::Application.routes.draw do
    get 'searchHal', to: 'hal#search_hal'
    get 'searchArticleOnHal', to: 'hal#search_article_on_hal'
    resources :projects do
      member do
        get 'timeline'
      end
    end
  end
end
