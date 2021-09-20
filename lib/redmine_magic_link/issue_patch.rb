require_dependency 'issue'

class Issue < ActiveRecord::Base

  has_many :magic_link_histories
  has_many :issue_magic_link_rules
  has_many :magic_link_rules, through: :issue_magic_link_rules

  after_create_commit :send_magic_links

  def send_magic_links
    MagicLinkRule.active.each do |magic_link_rule|
      contact_custom_field = magic_link_rule.contact_custom_field
      if self.available_custom_fields.include?(contact_custom_field)
        recipient = self.custom_value_for(contact_custom_field).value
        if recipient.present?
          Mailer.deliver_issue_add_with_magic_link(self, recipient, magic_link_rule)
        end
      end
    end
  end

  def create_new_membership_with_magic_link(user, magic_link_hash)
    issue_magic_link_rule = IssueMagicLinkRule.where(magic_link_hash: magic_link_hash).first
    if issue_magic_link_rule.present? && issue_magic_link_rule.issue == self
      member = Member.find_or_initialize_by(user: user, project: self.project)
      member.roles << issue_magic_link_rule.magic_link_rule.role
      member.save
    end
  end

  def self.random_magic_link_hash
    Redmine::Utils.random_hex(32).parameterize
  end

  def add_magic_link_hash(magic_link_rule)
    new_magic_link_hash = Issue.random_magic_link_hash
    IssueMagicLinkRule.find_or_create_by!(magic_link_hash: new_magic_link_hash,
                                          issue: self,
                                          magic_link_rule: magic_link_rule)
    new_magic_link_hash
  end

  def magic_link_hashes(magic_link_rule)
    issue_magic_link_rules.where(magic_link_rule: magic_link_rule).map(&:magic_link_hash)
  end

end
