class MagicLinkRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  safe_attributes "contact_custom_field_id", "role_id", "enabled"

  has_many :magic_link_history
  belongs_to :contact_custom_field, class_name: "CustomField"

  scope :active, -> { where(enabled: true) }

end
