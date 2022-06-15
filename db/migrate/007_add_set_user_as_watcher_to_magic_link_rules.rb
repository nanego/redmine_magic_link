class AddSetUserAsWatcherToMagicLinkRules < ActiveRecord::Migration[5.2]
  def change
    add_column :magic_link_rules, :set_user_as_watcher, :boolean, default: true
  end
end
