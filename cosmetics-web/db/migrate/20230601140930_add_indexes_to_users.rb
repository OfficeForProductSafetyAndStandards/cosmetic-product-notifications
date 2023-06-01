class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :users, :name, algorithm: :concurrently
    add_index :users, :email, algorithm: :concurrently
  end
end
