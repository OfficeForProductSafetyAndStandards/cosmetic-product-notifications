class AddOneloginIdToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :users, :onelogin_id, :string

    add_index :users, :onelogin_id, unique: true, algorithm: :concurrently
  end
end
