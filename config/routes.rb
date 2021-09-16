RedmineApp::Application.routes.draw do
  resources :magic_link_rules, except: :show
end
