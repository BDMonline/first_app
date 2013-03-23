class AddAuthorToElements < ActiveRecord::Migration
  def change
    add_column :elements, :author, :integer, default: 1
  end
end
