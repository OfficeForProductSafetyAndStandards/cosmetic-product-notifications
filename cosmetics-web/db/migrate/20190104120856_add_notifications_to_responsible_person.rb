class AddNotificationsToResponsiblePerson < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :notifications, :responsible_person, index: false, foreign_key: true
    add_index :notifications, :responsible_person_id, algorithm: :concurrently
  end
end
