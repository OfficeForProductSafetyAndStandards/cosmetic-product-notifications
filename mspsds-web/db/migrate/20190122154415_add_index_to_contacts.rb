class AddIndexToContacts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_column :contacts, :business_id, :string
    add_index :contacts, :business_id, algorithm: :concurrently
  end
end
