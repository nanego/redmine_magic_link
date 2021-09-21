class AddUserToMagicLinkHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :magic_link_histories, :user_id, :integer
  end
end
