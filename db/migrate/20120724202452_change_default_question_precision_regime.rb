class ChangeDefaultQuestionPrecisionRegime < ActiveRecord::Migration
  def change
  	change_column :questions, :precision_regime, :string, :default=>"s2"
  end
end
