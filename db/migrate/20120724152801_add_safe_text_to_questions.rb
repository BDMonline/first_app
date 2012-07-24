class AddSafeTextToQuestions < ActiveRecord::Migration
  def change
  	add_column :questions, :safe_text, :text, :default => ""
  end
end
