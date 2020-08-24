class AddNewEmailNewEmailConfirmationTokenAndNewEmailConfirmationTokenExpiresAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :new_email, :string
    add_column :users, :new_email_confirmation_token, :string
    add_column :users, :new_email_confirmation_token_expires_at, :datetime
  end
end
