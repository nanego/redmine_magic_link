require_dependency 'application_controller'

module PluginMagicLink
  module ApplicationController

    def check_twofa_activation
      super
      create_membership_if_magic_link_used
    end

    def create_membership_if_magic_link_used
      if params[:controller] == 'issues' && params[:action] == 'show' && params[:id].present? && params[:issue_key].present?
        issue_rule = IssueMagicLinkRule.where(magic_link_hash: params[:issue_key]).first
        if issue_rule.present? && issue_rule.issue_id == params[:id].to_i

          begin
            issue = Issue.find(params[:id])
          rescue ActiveRecord::RecordNotFound
            render_404
            return
          end
          if issue.present?
            issue.create_new_membership_with_magic_link(User.current, params[:issue_key]) unless issue.visible?(User.current)
            issue_rule.magic_link_rule.log_used_link(User.current, issue)
            issue_rule.issue.add_watcher(User.current) if issue_rule.magic_link_rule.set_user_as_watcher?
          end
          redirect_to issue_path(id: params[:id])
        end
      end
    end

  end
end

ApplicationController.prepend PluginMagicLink::ApplicationController
