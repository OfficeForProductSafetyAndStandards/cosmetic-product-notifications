class CreateContacts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_column :contacts, :business_id, :string
    add_index :contacts, :business_id, algorithm: :concurrently
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :description
      t.timestamps
    end
  end
end
