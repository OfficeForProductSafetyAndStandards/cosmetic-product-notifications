class RolifyCreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table(:roles) do |t|
      t.string :name, null: false
      t.references :resource, polymorphic: true

      t.timestamps
    end

    create_table(:users_roles, id: false) do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
    end

    add_index(:roles, %i[name resource_type resource_id], unique: true)
    add_index(:users_roles, %i[user_id role_id], unique: true)
  end
end