class AddUniqueIndexToNotifications < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notifications, %i[cpnp_reference responsible_person_id],
              unique: true,
              name: "index_notifications_on_cpnp_reference_and_rp_id",
              algorithm: :concurrently
  end
end
