class AddTagToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :tag, :text, :default => ""
  end
end
