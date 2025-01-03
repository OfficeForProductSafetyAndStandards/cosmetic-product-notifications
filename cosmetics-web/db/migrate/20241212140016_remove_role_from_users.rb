class RemoveRoleFromUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :users, :role, :string }
  end
end
