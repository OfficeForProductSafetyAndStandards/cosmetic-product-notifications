class CreateEmailVerificationKeys < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :email_verification_keys do |t|
      t.string :key
      t.datetime :expires_at

      t.timestamps
    end

    add_reference :email_verification_keys, :responsible_person, foreign_key: true, index: false
    add_index :email_verification_keys, :responsible_person_id, algorithm: :concurrently
  end
end
