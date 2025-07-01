class AddMissingIndexes < ActiveRecord::Migration[7.2]
  def change

    if Redmine::Plugin.installed?(:redmine_limited_visibility)
      add_index :functions_magic_link_rules, :function_id, if_not_exists: true
      add_index :functions_magic_link_rules, [:function_id, :magic_link_rule_id], if_not_exists: true
    end

    add_index :issue_magic_link_rules, :issue_id, if_not_exists: true
    add_index :issue_magic_link_rules, :magic_link_rule_id, if_not_exists: true

    add_index :magic_link_histories, :issue_id, if_not_exists: true
    add_index :magic_link_histories, :magic_link_rule_id, if_not_exists: true
    add_index :magic_link_histories, :user_id, if_not_exists: true

    add_index :magic_link_rules, :contact_custom_field_id, if_not_exists: true
    add_index :magic_link_rules, :role_id, if_not_exists: true
    add_index :magic_link_rules_roles, :role_id, if_not_exists: true
    add_index :magic_link_rules_roles, [:magic_link_rule_id, :role_id], if_not_exists: true

  end
end
