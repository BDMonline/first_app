class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.string :type
      t.string :name
      t.text :content
      t.text :tags

      t.timestamps
    end
  end
end
