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
          issue = Issue.find(params[:id])
          issue.create_new_membership_with_magic_link(User.current, params[:issue_key]) unless issue.visible?(User.current)
          issue_rule.magic_link_rule.log_used_link(User.current, issue)
          redirect_to issue_path(id: params[:id])
        end
      end
    end

  end
end

ApplicationController.prepend PluginMagicLink::ApplicationController
