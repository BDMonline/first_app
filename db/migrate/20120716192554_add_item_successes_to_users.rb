class AddItemSuccessesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :item_successes, :text, :default => "[]"
  end
end
