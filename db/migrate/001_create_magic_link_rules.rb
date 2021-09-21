class CreateMagicLinkRules < ActiveRecord::Migration[5.2]
  def change
    create_table :magic_link_rules do |t|
      t.integer :contact_custom_field_id
      t.boolean :enabled
      t.integer :role_id
      t.timestamps null: false
    end
  end
end
