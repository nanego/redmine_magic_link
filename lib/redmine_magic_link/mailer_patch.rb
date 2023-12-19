require 'mailer'

module RedmineMagicLink
  module MailerPatch

    # Builds a mail for notifying recipient about a new issue
    def issue_add_with_magic_link(user, recipient_address, issue, magic_link_hash)
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Tracker' => issue.tracker.name,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      message_id issue
      references issue
      @author = issue.author
      @issue = issue
      @user = user
      @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :issue_key => magic_link_hash)
      subject = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}]"
      subject += " (#{issue.status.name})" if Setting.show_status_changes_in_mail_subject?
      subject += " #{issue.subject}"
      mail :to => recipient_address,
           :subject => subject
    end

    # Builds a mail for notifying user about an issue update
    def issue_edit_with_magic_link(user, recipient_address, issue, journal, magic_link_hash)
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Tracker' => issue.tracker.name,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      message_id journal
      references issue
      @author = journal.user
      s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
      s += "(#{issue.status.name}) " if journal.new_value_for('status_id') && Setting.show_status_changes_in_mail_subject?
      s += issue.subject
      @issue = issue
      @user = user
      @journal = journal
      @journal_details = journal.visible_details
      @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :issue_key => magic_link_hash, :anchor => "change-#{journal.id}")

      mail :to => recipient_address,
           :subject => s
    end

  end
end

class Mailer < ActionMailer::Base

  prepend RedmineMagicLink::MailerPatch

  def self.deliver_issue_add_with_magic_link(issue, recipient_address, magic_link_rule)
    magic_link_hash = issue.add_magic_link_hash(magic_link_rule)
    recipients_addresses = recipient_address.split(',')
    recipients_addresses.each do |address|
      issue_add_with_magic_link(User.current, address, issue, magic_link_hash).deliver_later
    end
    magic_link_rule.log_new_link_sent(issue, recipient_address)
  end

  def self.deliver_issue_edit_with_magic_link(issue, journal, recipient_address, magic_link_rule)
    magic_link_hash = issue.add_magic_link_hash(magic_link_rule)
    recipients_addresses = recipient_address.split(',')
    recipients_addresses.each do |address|
      issue_edit_with_magic_link(User.current, address, issue, journal, magic_link_hash).deliver_later
    end
    magic_link_rule.log_link_sent(issue, recipient_address)
  end

end
