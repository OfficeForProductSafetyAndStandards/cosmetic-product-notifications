class CreatePendingResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :pending_responsible_person_users do |t|
      t.string :email_address
      t.datetime :expires_at

      t.timestamps
    end

    add_reference :pending_responsible_person_users, :responsible_person, foreign_key: true, index: false
    add_index :pending_responsible_person_users, :responsible_person_id, algorithm: :concurrently
  end
end
