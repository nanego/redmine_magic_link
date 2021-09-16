require_dependency 'issue'

class Issue < ActiveRecord::Base

  include Redmine::SafeAttributes
  safe_attributes 'magic_link_hash'

  has_many :magic_link_histories

  after_create_commit :send_magic_links

  def send_magic_links
    MagicLinkRule.active.each do |magic_link_rule|
      contact_custom_field = magic_link_rule.contact_custom_field
      if self.available_custom_fields.include?(contact_custom_field)
        recipient = self.custom_value_for(contact_custom_field).value
        if recipient.present?
          Mailer.deliver_issue_add_with_magic_link(self, recipient)
        end
      end
    end
  end

  def self.random_magic_link_hash
    Redmine::Utils.random_hex(32)
  end

  def add_magic_link_hash
    self.update_columns magic_link_hash: Issue.random_magic_link_hash if magic_link_hash.blank?
  end

end
