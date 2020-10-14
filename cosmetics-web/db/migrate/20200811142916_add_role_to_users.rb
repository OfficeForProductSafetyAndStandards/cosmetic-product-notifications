class AddRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      create_enum :user_roles, %w(poison_centre market_surveilance_authority)

      add_column :users, :role, :user_roles
    end
  end
end
