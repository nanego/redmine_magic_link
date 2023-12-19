module RedmineMagicLink
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("magic_link", :plugin => "redmine_magic_link")
    end
  end

  class ModelHooks < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'issue_patch'
      require_relative 'journal_patch'
      require_relative 'mailer_patch'
      require_relative 'application_controller_patch'
    end
  end
end
