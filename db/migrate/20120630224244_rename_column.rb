class RenameColumn < ActiveRecord::Migration
  def change
    rename_column :Elements, :type, :category
  end
end
