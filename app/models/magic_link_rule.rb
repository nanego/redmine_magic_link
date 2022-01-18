class MagicLinkRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  safe_attributes "contact_custom_field_id",
                  "role_id",
                  "enabled",
                  "enabled_for_unregistered_watchers"

  has_many :magic_link_histories
  has_many :issue_magic_link_rules
  has_many :issues, through: :issue_magic_link_rules
  belongs_to :role
  belongs_to :contact_custom_field, class_name: "CustomField"

  scope :active, -> { where(enabled: true) }

  def log_new_link_sent(issue, address = nil)
    if address.nil?
      log_new_link_sent_to_unregistered_watchers(issue)
    else
      self.magic_link_histories.create!(issue: issue, description: "New link sent to: #{address}")
    end
  end

  def log_new_link_sent_to_unregistered_watchers(issue)
    self.magic_link_histories.create!(issue: issue, description: "New link sent to unregistered watchers")
  end

  def log_link_sent(issue, address)
    self.magic_link_histories.create!(issue: issue, description: "Link sent to: #{address}")
  end

  def log_used_link(user, issue)
    self.magic_link_histories.create!(issue: issue, description: "Link used by: #{user}", user: user)
  end

  def log_added_role(user, issue, role)
    self.magic_link_histories.create!(issue: issue, description: "Role #{role} assigned to user #{user}", user: user)
  end

end
