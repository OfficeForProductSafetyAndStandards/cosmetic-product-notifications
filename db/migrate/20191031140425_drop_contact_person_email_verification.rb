class DropContactPersonEmailVerification < ActiveRecord::Migration[5.2]
  def change
    drop_table :email_verification_keys do |table|
      table.string :key
      table.datetime :expires_at
      table.timestamps
      table.references :contact_person, foreign_key: true
    end

    safety_assured do
      remove_column :contact_persons, :email_verified, :boolean, default: false
    end
  end
end
