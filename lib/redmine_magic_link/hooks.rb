module RedmineMagicLink
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("magic_link", :plugin => "redmine_magic_link")
    end
  end
end
