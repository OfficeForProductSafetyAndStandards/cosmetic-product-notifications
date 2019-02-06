class RenameTeamMemberToResponsiblePersonUser < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :team_members, :responsible_person_users
    end
  end
end
