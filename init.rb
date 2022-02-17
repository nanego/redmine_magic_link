require 'redmine_magic_link/hooks'

ActiveSupport::Reloader.to_prepare do
  require_dependency 'redmine_magic_link/issue_patch'
  require_dependency 'redmine_magic_link/mailer_patch'
  require_dependency 'redmine_magic_link/journal_patch'
  require_dependency 'redmine_magic_link/application_controller_patch'
end

Redmine::Plugin.register :redmine_magic_link do
  name 'Redmine Magic Link'
  author 'Vincent ROBERT'
  description 'This is a plugin for Redmine which allows you to send Magic links to users'
  version '1.0.0'
  url 'https://github.com/nanego/redmine_magic_link'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.4' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  menu :admin_menu, :magic_link_rules, { :controller => 'magic_link_rules', :action => 'index' },
       :caption => :label_magic_links,
       :html => {:class => 'icon'}
  settings :default => { 'technical_user' => nil},
           :partial => 'settings/redmine_plugin_magic_link'
end
