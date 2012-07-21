class AddTagsToQuestions < ActiveRecord::Migration
  def change
  	add_column :questions, :tags, :text, :default => ""
  	add_index :questions, :tags
  end
end
