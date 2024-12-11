class AddLegacyRoleAndLegacyTypeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :legacy_role, :string
    add_column :users, :legacy_type, :string
  end
end
