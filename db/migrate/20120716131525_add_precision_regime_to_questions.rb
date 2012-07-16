class AddPrecisionRegimeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :precision_regime, :string, :default => "2s"
  end
end
