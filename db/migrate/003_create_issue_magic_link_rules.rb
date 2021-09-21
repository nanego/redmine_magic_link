class CreateIssueMagicLinkRules < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_magic_link_rules do |t|
      t.integer :magic_link_rule_id
      t.integer :issue_id
      t.string :magic_link_hash
      t.timestamps null: false
    end
  end
end
