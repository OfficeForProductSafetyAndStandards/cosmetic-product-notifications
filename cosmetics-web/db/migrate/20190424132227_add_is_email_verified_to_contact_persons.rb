class AddIsEmailVerifiedToContactPersons < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_persons, :is_email_verified, :boolean
  end
end
