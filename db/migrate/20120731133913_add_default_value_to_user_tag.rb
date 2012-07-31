class AddDefaultValueToUserTag < ActiveRecord::Migration
  def change
  	change_column :users, :tag, :text, :default=>""
  end
end
