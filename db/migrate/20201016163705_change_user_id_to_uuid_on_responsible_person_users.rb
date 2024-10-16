class ChangeUserIdToUuidOnResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :responsible_person_users, :user_id, :old_user_id
      add_column :responsible_person_users, :user_id, :uuid, default: "gen_random_uuid()"
    end
  end
end
