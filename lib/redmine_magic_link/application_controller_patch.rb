require_dependency 'application_controller'

class IssuesController < ApplicationController

  prepend_before_action :create_membership_if_magic_link_used, :only => [:show]

  def create_membership_if_magic_link_used
    if params[:issue_key].present?
      issue_rule = IssueMagicLinkRule.where(magic_link_hash: params[:issue_key]).first
      if issue_rule.present? && issue_rule.issue_id == params[:id].to_i
        issue = Issue.find(params[:id])
        issue.create_new_membership_with_magic_link(User.current, params[:issue_key]) unless issue.visible?(User.current)
      end
    end
  end

end
