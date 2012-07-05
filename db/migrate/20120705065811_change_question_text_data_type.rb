class ChangeQuestionTextDataType < ActiveRecord::Migration
  def self.up
    change_table :questions do |t|
      t.change :text, :text
    end
  end

  def self.down
    change_table :questions do |t|
      t.change :text, :string
    end
  end
end
