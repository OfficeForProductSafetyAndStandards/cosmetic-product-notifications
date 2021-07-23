class AddNameToPendingResponsiblePersonUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :pending_responsible_person_users, :name, :string, null: true
  end
end
