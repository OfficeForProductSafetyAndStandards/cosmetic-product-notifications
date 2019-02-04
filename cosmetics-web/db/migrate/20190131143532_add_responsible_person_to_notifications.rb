class AddResponsiblePersonToNotifications < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :notifications, :responsible_person, foreign_key: true, index: false
    add_index :notifications, :responsible_person_id, algorithm: :concurrently
  end
end
