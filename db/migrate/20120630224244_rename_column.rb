class RenameColumn < ActiveRecord::Migration
  def change
    rename_column :elements, :type, :category
  end
end
