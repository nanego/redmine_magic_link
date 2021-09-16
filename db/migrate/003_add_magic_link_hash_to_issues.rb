class AddMagicLinkHashToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :magic_link_hash, :string, default: ""
  end
end
