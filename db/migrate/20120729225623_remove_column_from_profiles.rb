class RemoveColumnFromProfiles < ActiveRecord::Migration
  def up
    remove_column :profiles, :item_successes
  end

  def down
    add_column :profiles, :item_successes, :text
  end
end
