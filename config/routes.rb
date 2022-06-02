RedmineApp::Application.routes.draw do
  resources :magic_link_rules
  resources :magic_link_histories, only: :index
end
