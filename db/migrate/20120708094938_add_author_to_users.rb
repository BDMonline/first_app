class AddAuthorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :author, :boolean
  end
end
