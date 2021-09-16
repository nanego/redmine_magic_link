class MagicLinkHistory < ActiveRecord::Base

  include Redmine::SafeAttributes

  safe_attributes "magic_link_rule_id", "issue_id", "description"

  belongs_to :magic_link_rule
  belongs_to :issue

  def to_s
    description
  end

end
