class AddAuthorToItems < ActiveRecord::Migration
  def change
    add_column :items, :author, :integer, default:1
  end
end
