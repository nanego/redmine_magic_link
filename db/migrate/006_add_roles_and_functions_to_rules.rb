class AddRolesAndFunctionsToRules < ActiveRecord::Migration[5.2]
  def change
    create_join_table :magic_link_rules, :roles
    create_join_table :magic_link_rules, :functions if Redmine::Plugin.installed?(:redmine_limited_visibility)

    MagicLinkRule.all.each do |rule|
      rule.roles << Role.find(rule.role_id)
      rule.save
    end
  end
end
