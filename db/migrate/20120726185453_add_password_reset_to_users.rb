class AddPasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_token, :string
    add_column :users, :token_send_time, :datetime
  end
end
