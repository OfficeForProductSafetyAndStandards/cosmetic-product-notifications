class AddEncryptedTotpSecretKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.text    :encrypted_totp_secret_key
        t.integer :last_totp_at
      end
    end
  end
end
