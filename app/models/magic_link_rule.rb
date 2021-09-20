class MagicLinkRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  safe_attributes "contact_custom_field_id", "role_id", "enabled"

  has_many :magic_link_histories
  has_many :issue_magic_link_rules
  has_many :issues, through: :issue_magic_link_rules
  belongs_to :role
  belongs_to :contact_custom_field, class_name: "CustomField"

  scope :active, -> { where(enabled: true) }

end
