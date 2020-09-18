class AddAccountSecurityCompletedToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.column :account_security_completed, :boolean, default: false
      end
    end
  end
end
