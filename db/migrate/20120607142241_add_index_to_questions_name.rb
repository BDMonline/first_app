class AddIndexToQuestionsName < ActiveRecord::Migration
  def change
  	add_index :questions, :name, unique: true
  end
end
