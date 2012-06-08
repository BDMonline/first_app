class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :name
      t.string :parameters
      t.string :answers

      t.timestamps
    end
  end
end
