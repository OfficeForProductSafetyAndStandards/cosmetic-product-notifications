class RemoveOldUserIdFromResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :responsible_person_users, :old_user_id, :string }
  end
end
