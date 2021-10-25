require "spec_helper"
require "active_support/testing/assertions"
require_dependency 'application_controller'

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
    User.current = User.find(2)
    @request.session[:user_id] = 2
    Setting.plain_text_mail = 0
    Setting.default_language = 'en'
    MagicLinkRule.update_all(enabled: true)
  end

  let!(:user) { User.find(2) }
  let!(:issue) { Issue.find(1) }
  let!(:project) { Project.find(1) }

  describe "New issue notification with magic link" do
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
      new_issue_magic_link_rule = IssueMagicLinkRule.last

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => new_issue.id)

      expect(ActionMailer::Base.deliveries.size).to eq 3
      expect(new_issue_magic_link_rule.issue).to eq new_issue
      expect(new_issue.magic_link_hashes(new_issue_magic_link_rule))

      default_mail = ActionMailer::Base.deliveries.second
      expect(default_mail['bcc'].value).to include User.find(2).mail
      expect(default_mail['bcc'].value).to_not include "non_member_contact@example.net"
      default_mail.parts.each do |part|
        expect(part.body.raw_source).to include "has been reported by"
        expect(part.body.raw_source).to_not include "?issue_key="
      end

      mail_with_magic_link = ActionMailer::Base.deliveries.first
      expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
      expect(mail_with_magic_link['bcc'].value).to include "non_member_contact@example.net"
      mail_with_magic_link.parts.each do |part|
        expect(part.body.raw_source).to include "has been reported by"
        expect(part.body.raw_source).to include "?issue_key=#{new_issue_magic_link_rule.magic_link_hash}"
      end
    end

    it "should send a notification including magic-link after create to multiple recipients if using multiple addresses" do
      ActionMailer::Base.deliveries.clear

      assert_difference 'Issue.count' do
        post :create, params: { :project_id => 1,
                                :issue => { :tracker_id => 3,
                                            :subject => 'This is the test_new issue',
                                            :description => 'This is the description',
                                            :priority_id => 5,
                                            :custom_field_values => { '2' => 'non_member_contact@example.net,second_ext_contact@example.net' } } }
      end

      new_issue = Issue.last
      new_issue_magic_link_rule = IssueMagicLinkRule.last

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => new_issue.id)

      expect(ActionMailer::Base.deliveries.size).to eq 4
      expect(new_issue_magic_link_rule.issue).to eq new_issue
      expect(new_issue.magic_link_hashes(new_issue_magic_link_rule))

      default_mail = ActionMailer::Base.deliveries.third
      expect(default_mail['bcc'].value).to include User.find(2).mail
      expect(default_mail['bcc'].value).to_not include "non_member_contact@example.net"
      default_mail.parts.each do |part|
        expect(part.body.raw_source).to include "has been reported by"
        expect(part.body.raw_source).to_not include "?issue_key="
      end

      mail_with_magic_link = ActionMailer::Base.deliveries.first
      expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
      expect(mail_with_magic_link['bcc'].value).to include "non_member_contact@example.net"
      expect(mail_with_magic_link['bcc'].value).to_not include "second_ext_contact@example.net"
      mail_with_magic_link.parts.each do |part|
        expect(part.body.raw_source).to include "has been reported by"
        expect(part.body.raw_source).to include "?issue_key=#{new_issue_magic_link_rule.magic_link_hash}"
      end

      mail_with_magic_link = ActionMailer::Base.deliveries.second
      expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
      expect(mail_with_magic_link['bcc'].value).to_not include "non_member_contact@example.net"
      expect(mail_with_magic_link['bcc'].value).to include "second_ext_contact@example.net"
      mail_with_magic_link.parts.each do |part|
        expect(part.body.raw_source).to include "has been reported by"
        expect(part.body.raw_source).to include "?issue_key=#{new_issue_magic_link_rule.magic_link_hash}"
      end
    end

    it "should send a notification including magic-link after create even if nobody else is notified" do
      ActionMailer::Base.deliveries.clear
      project.members.destroy_all
      expect(project.notified_users).to be_empty
      expect(project.users).to be_empty
      user.pref.no_self_notified = true
      user.pref.save

      assert_difference 'Issue.count' do
        post :create, params: { :project_id => 1,
                                :issue => { :tracker_id => 3,
                                            :subject => 'This is the test_new issue',
                                            :description => 'This is the description',
                                            :priority_id => 5,
                                            :custom_field_values => { '2' => 'non_member_contact@example.net' } } }
      end

      new_issue = Issue.last
      new_issue_magic_link_rule = IssueMagicLinkRule.last

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => new_issue.id)

      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(new_issue_magic_link_rule.issue).to eq new_issue
      expect(new_issue.magic_link_hashes(new_issue_magic_link_rule))

      mail_with_magic_link = ActionMailer::Base.deliveries.first
      expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
      expect(mail_with_magic_link['bcc'].value).to include "non_member_contact@example.net"
      mail_with_magic_link.parts.each do |part|
        expect(part.body.raw_source).to include "has been reported by"
        expect(part.body.raw_source).to include "?issue_key=#{new_issue_magic_link_rule.magic_link_hash}"
      end
    end

    it "should log every magic link sent after create" do

      assert_difference 'MagicLinkHistory.count' do
        assert_difference 'Issue.count' do
          post :create, params: { :project_id => 1,
                                  :issue => { :tracker_id => 3,
                                              :subject => 'This is the test_new issue',
                                              :description => 'This is the description',
                                              :priority_id => 5,
                                              :custom_field_values => { '2' => 'non_member_contact@example.net' } } }
        end
      end

      new_issue = Issue.last
      magic_link_rule = MagicLinkRule.first
      history = MagicLinkHistory.last

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => new_issue.id)

      # New log entry
      expect(history.magic_link_rule).to eq magic_link_rule
      expect(history.issue).to eq new_issue
      expect(history.description).to include "New link sent to: non_member_contact@example.net"
    end
  end

  describe "Edit issue notification with magic link" do
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
      issue_magic_link_rule = IssueMagicLinkRule.where(issue: updated_issue).last
      default_mail = ActionMailer::Base.deliveries.second
      mail_with_magic_link = ActionMailer::Base.deliveries.first

      expect(default_mail['bcc'].value).to include User.find(2).mail
      expect(default_mail['bcc'].value).to_not include "other_contact@example.net"
      default_mail.parts.each do |part|
        expect(part.body.raw_source).to include "has been updated by"
        expect(part.body.raw_source).to_not include "issue_key="
      end

      expect(mail_with_magic_link['bcc'].value).to_not include User.find(2).mail
      expect(mail_with_magic_link['bcc'].value).to include "other_contact@example.net"
      mail_with_magic_link.parts.each do |part|
        expect(part.body.raw_source).to include "has been updated by"
        expect(part.body.raw_source).to include "?issue_key=#{issue_magic_link_rule.magic_link_hash}"
      end
    end

    it "should log every link sent after update" do

      assert_difference 'MagicLinkHistory.count' do
        assert_difference 'Journal.count' do
          assert_difference('JournalDetail.count', 2) do
            put :update, params: { :id => 1,
                                   :issue => {
                                     status_id: '5', # close issue
                                     custom_field_values: { '2' => 'other_contact@example.net' }
                                   } }
          end
        end
      end

      updated_issue = Issue.find(1)
      magic_link_rule = MagicLinkRule.first
      history = MagicLinkHistory.last

      # New log entry
      expect(history.magic_link_rule).to eq magic_link_rule
      expect(history.issue).to eq updated_issue
      expect(history.description).to include "Link sent to: other_contact@example.net"

    end
  end

  describe "Show issue with magic link" do

    before do
      Role.find(1).remove_permission!(:view_issues)
      Role.find(5).remove_permission!(:view_issues) # Anonymous
    end

    it "should NOT allow to see the issue if user has no permission" do
      get :show, params: { :id => 1 }
      assert_response 403
    end

    it "should NOT allow to see the issue if magic link does not match" do
      IssueMagicLinkRule.create(issue_id: 1, magic_link_rule_id: 1, magic_link_hash: "AZERTY")
      get :show, params: { :id => 1, issue_key: "LADIDA" }
      assert_response 403 # Forbidden
    end

    it "should allow to see the issue if magic link is correct" do
      expect(user.roles_for_project(project).map(&:id)).to eq [1]

      IssueMagicLinkRule.create(issue_id: 1, magic_link_rule_id: 1, magic_link_hash: "AZERTY")
      assert_difference 'MagicLinkHistory.count', 2 do
        get :show, params: { :id => 1, issue_key: "AZERTY" }
      end

      expect(user.reload.roles_for_project(project).map(&:id)).to eq [1, 2]
      expect(response).to redirect_to('/issues/1')

      # New log entry
      history = MagicLinkHistory.last
      expect(history.magic_link_rule_id).to eq 1
      expect(history.issue_id).to eq 1
      expect(history.user_id).to eq 2
      expect(history.description).to include "Link used by: John Smith"

    end

    it "should NOT allow to see the issue if magic link is correct BUT rule is disabled" do
      MagicLinkRule.where(id: 1).update(enabled: false)
      expect(user.roles_for_project(project).map(&:id)).to eq [1]

      IssueMagicLinkRule.create(issue_id: 1, magic_link_rule_id: 1, magic_link_hash: "AZERTY")
      assert_difference 'MagicLinkHistory.count', 1 do
        get :show, params: { :id => 1, issue_key: "AZERTY" }
      end

      expect(user.reload.roles_for_project(project).map(&:id)).to eq [1]
      expect(response).to redirect_to('/issues/1')

      # New log entry
      history = MagicLinkHistory.last
      expect(history.magic_link_rule_id).to eq 1
      expect(history.issue_id).to eq 1
      expect(history.user_id).to eq 2
      expect(history.description).to include "Link used by: John Smith"
    end

  end

end
