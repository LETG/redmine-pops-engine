Rails.application.routes.draw do

  mount PopsRedmineEngine::Engine => "/pops_redmine_engine"
end
