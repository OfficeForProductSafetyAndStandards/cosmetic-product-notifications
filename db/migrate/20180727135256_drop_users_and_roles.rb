class DropUsersAndRoles < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :investigations, :users
    remove_foreign_key :sources, :users
    drop_table :users_roles
    drop_table :users
    drop_table :roles
  end
end
