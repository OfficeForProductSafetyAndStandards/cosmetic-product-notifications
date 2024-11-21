class AddLegacyRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :legacy_role, :string
  end
end
