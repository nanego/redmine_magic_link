class AddActivatedForUnregisteredWatchersToMagicLinkRules < ActiveRecord::Migration[5.2]
  def change
    add_column :magic_link_rules, :enabled_for_unregistered_watchers, :boolean, default: false
  end
end
