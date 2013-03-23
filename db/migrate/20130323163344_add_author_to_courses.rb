class AddAuthorToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :author, :integer, default:1
  end
end
