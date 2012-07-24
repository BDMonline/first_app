class AddSafeContentToElements < ActiveRecord::Migration
  def change
  	add_column :elements, :safe_content, :text, :default => ""
  end
end
