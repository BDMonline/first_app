class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user
      t.integer :course
      t.text :tag
      t.text :item_successes, :default=>""
      t.text :feedback

      t.timestamps
    end
  end
end
