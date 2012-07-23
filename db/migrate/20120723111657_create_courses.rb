class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.text :name
      t.text :tags
      t.text :content, :default=>"[]"

      t.timestamps
    end
  end
end
