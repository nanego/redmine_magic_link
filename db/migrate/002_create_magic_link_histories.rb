class CreateMagicLinkHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :magic_link_histories do |t|
      t.integer :magic_link_rule_id
      t.integer :issue_id
      t.text :description
      t.timestamps null: false
    end
  end
end
