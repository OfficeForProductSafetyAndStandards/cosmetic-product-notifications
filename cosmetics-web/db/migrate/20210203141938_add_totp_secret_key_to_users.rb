class AddTotpSecretKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :totp_secret_key, :string
    add_column :users, :last_totp_at, :integer
  end
end
