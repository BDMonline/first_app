class AddAuthorToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :author, :integer, default:1
  end
end
