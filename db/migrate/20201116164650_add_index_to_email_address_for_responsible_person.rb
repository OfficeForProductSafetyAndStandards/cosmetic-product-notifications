class AddIndexToEmailAddressForResponsiblePerson < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pending_responsible_person_users,
              %i[responsible_person_id email_address],
              algorithm: :concurrently,
              unique: true,
              name: "index_pending_responsible_person_users_on_rp_and_email"
  end
end
