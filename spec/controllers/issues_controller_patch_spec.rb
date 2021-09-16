require "spec_helper"
require "active_support/testing/assertions"

describe IssuesController, type: :controller do

  render_views

  include ActiveSupport::Testing::Assertions

  fixtures :users, :email_addresses, :user_preferences,
           :roles, :members, :member_roles,
           :issues, :issue_statuses, :issue_relations,
           :versions, :trackers, :projects_trackers,
           :issue_categories, :enabled_modules, :enumerations,
           :attachments, :workflows,
           :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details,
           :queries, :repositories, :changesets, :projects,
           :magic_link_rules

  before do
    # User.current = User.find(2)
    @request.session[:user_id] = 2
    Setting.plain_text_mail = 0
    Setting.default_language = 'en'
    MagicLinkRule.update_all(enabled: true)
  end

  it "should send a notification including magic-link after create" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'Issue.count' do
      post :create, params: { :project_id => 1,
                              :issue => { :tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :custom_field_values => { '2' => 'non_member_contact@example.net' } } }
    end

    new_issue = Issue.last
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => new_issue.id)

    expect(ActionMailer::Base.deliveries.size).to eq 3

    default_mail = ActionMailer::Base.deliveries.second
    expect(default_mail['bcc'].value).to include User.find(2).mail
    expect(default_mail['bcc'].value).to_not include "non_member_contact@example.net"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been reported by"
      expect(part.body.raw_source).to_not include "?key="
    end

    mail_with_magic_link = ActionMailer::Base.deliveries.first
    expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
    expect(mail_with_magic_link['bcc'].value).to include "non_member_contact@example.net"
    mail_with_magic_link.parts.each do |part|
      expect(part.body.raw_source).to include "has been reported by"
      expect(part.body.raw_source).to include "?key=#{new_issue.magic_link_hash}"
    end
  end

  it "should send a notification including magic-link after update" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 2) do
        put :update, params: { :id => 1,
                               :issue => {
                                 status_id: '5', # close issue
                                 custom_field_values: { '2' => 'other_contact@example.net' }
                               } }
      end
    end
    expect(ActionMailer::Base.deliveries.size).to eq 3 # 2 standards + 1

    updated_issue = Issue.find(1)
    default_mail = ActionMailer::Base.deliveries.second
    mail_with_magic_link = ActionMailer::Base.deliveries.first

    expect(default_mail['bcc'].value).to include User.find(2).mail
    expect(default_mail['bcc'].value).to_not include "other_contact@example.net"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to_not include "?key=#{updated_issue.magic_link_hash}"
    end

    expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
    expect(mail_with_magic_link['bcc'].value).to include "other_contact@example.net"
    mail_with_magic_link.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to include "?key=#{updated_issue.magic_link_hash}"
    end
  end

end
