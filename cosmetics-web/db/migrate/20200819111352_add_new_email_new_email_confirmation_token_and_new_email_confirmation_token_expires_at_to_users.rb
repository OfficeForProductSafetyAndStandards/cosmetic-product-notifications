class AddNewEmailNewEmailConfirmationTokenAndNewEmailConfirmationTokenExpiresAtToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.column :new_email, :string
        t.column :new_email_confirmation_token, :string
        t.column :new_email_confirmation_token_expires_at, :datetime
      end
    end
  end
end
