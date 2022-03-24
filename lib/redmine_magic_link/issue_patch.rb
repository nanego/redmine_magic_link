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
    if issue_magic_link_rule.present? && issue_magic_link_rule.issue == self && issue_magic_link_rule.magic_link_rule&.enabled
      member = Member.find_or_initialize_by(user: user, project: self.project)
      member.roles |= issue_magic_link_rule.magic_link_rule.roles
      member.functions |= issue_magic_link_rule.magic_link_rule.functions
      member.save
      issue_magic_link_rule.magic_link_rule.log_added_roles(user, self, issue_magic_link_rule.magic_link_rule.roles)
      journalize_member_creation_in_project_history(member: member,
                                                    roles: issue_magic_link_rule.magic_link_rule.roles,
                                                    functions: issue_magic_link_rule.magic_link_rule.functions) if Redmine::Plugin.installed?(:redmine_admin_activity)
    end
  end

  def self.random_magic_link_hash
    Redmine::Utils.random_hex(32).parameterize
  end

  def add_magic_link_hash(magic_link_rule)
    rule = IssueMagicLinkRule.where(issue: self,
                                    magic_link_rule: magic_link_rule).first_or_initialize
    rule.magic_link_hash = Issue.random_magic_link_hash unless rule.magic_link_hash.present?
    if rule.save
      rule.magic_link_hash
    end
  end

  def magic_link_hashes(magic_link_rule)
    issue_magic_link_rules.where(magic_link_rule: magic_link_rule).map(&:magic_link_hash)
  end

  def journalize_member_creation_in_project_history(member:, roles:, functions: [])

    if functions.present?
      value = "{ \"name\": \"#{member.principal.to_s}\", \"roles\": [#{roles.map { |r| "\"#{r.name}\"" }.join(', ')}], \"functions\": [#{functions.map { |f| "\"#{f.name}\"" }.join(', ')}] }"
    else
      value = "{ \"name\": \"#{member.principal.to_s}\", \"roles\": [#{roles.map { |r| "\"#{r.name}\"" }.join(', ')}] }"
    end

    user = User.where(id: Setting["plugin_redmine_magic_link"]["technical_user"]).first
    self.project.init_journal(user || User.current)
    self.project.current_journal.details << JournalDetail.new(
      property: 'members',
      prop_key: functions.present? ? 'member_roles_and_functions' : 'member_with_roles',
      value: value)
    self.project.current_journal.save
  end

end
