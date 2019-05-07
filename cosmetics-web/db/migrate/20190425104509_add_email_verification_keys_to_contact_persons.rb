class AddEmailVerificationKeysToContactPersons < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_reference :email_verification_keys, :contact_person, foreign_key: true, index: false
    add_index :email_verification_keys, :contact_person_id, algorithm: :concurrently
  end
end
