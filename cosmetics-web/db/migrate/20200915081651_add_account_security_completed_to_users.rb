class AddAccountSecurityCompletedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :account_security_completed, :boolean
    change_column_default :users, :account_security_completed, false
  end
end
