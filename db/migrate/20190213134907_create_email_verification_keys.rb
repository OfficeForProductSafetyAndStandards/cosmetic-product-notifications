class CreateEmailVerificationKeys < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      create_table :email_verification_keys do |t|
        t.string :key
        t.datetime :expires_at

        t.timestamps
      end

      add_reference :email_verification_keys, :responsible_person, foreign_key: true, index: true
    end
  end
end
