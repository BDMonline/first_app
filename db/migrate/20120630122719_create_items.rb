class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :tags
      t.text :content
      t.text :markpolicy

      t.timestamps
    end
  end
end
