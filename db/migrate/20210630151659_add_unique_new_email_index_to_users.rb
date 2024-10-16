class AddUniqueNewEmailIndexToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :users, :new_email, unique: true, algorithm: :concurrently
  end
end
