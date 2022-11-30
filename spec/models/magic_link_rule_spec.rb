require "spec_helper"

describe "MagicLinkRule" do
  fixtures :custom_fields, :roles      

  include Redmine::I18n

  context "Update relationship tables on cascading delete" do

    it "when deleting a custom_field" do
      custom_field_test = CustomField.find(2)      
      custom_field_test.destroy
      expect(MagicLinkRule.first.contact_custom_field_id).to be_nil
    end

    it "when deleting a role" do
      role_test = Role.create!(:name => 'Test')
      CustomField.connection.execute("INSERT INTO magic_link_rules_roles (magic_link_rule_id, role_id) VALUES (1, #{role_test.id})")
      expect(ActiveRecord::Base.connection.execute('select * from magic_link_rules_roles').count).to eq(1)
      
      role_test.destroy
      expect(ActiveRecord::Base.connection.execute('select * from magic_link_rules_roles').count).to eq(0)
    end

    if Redmine::Plugin.installed?(:redmine_limited_visibility) 
      it "when deleting a function" do
        function_test = Function.create!(:name => 'Test')
        ActiveRecord::Base.connection.execute("INSERT INTO functions_magic_link_rules (magic_link_rule_id, function_id) VALUES (1, #{function_test.id})")
      
        expect(ActiveRecord::Base.connection.execute('select * from functions_magic_link_rules').count).to eq(1)
  
        function_test.destroy
        expect(ActiveRecord::Base.connection.execute('select * from functions_magic_link_rules').count).to eq(0)
      end
    end
  end  
end
