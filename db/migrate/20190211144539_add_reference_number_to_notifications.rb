class AddReferenceNumberToNotifications < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :notifications, :reference_number, :integer
    add_index :notifications, :reference_number, algorithm: :concurrently, unique: true
  end
end
