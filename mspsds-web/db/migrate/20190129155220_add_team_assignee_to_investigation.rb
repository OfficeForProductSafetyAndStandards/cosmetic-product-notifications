class AddTeamAssigneeToInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          t.string :assignable_type
          t.rename :assignee_id, :assignable_id

          dir.up do
            Investigation.where.not(assignable_id: nil).update_all(assignable_type: "User")
            remove_index :investigations, :assignable_id
            add_index :investigations, %i[assignable_type assignable_id]
          end

          dir.down do
            Investigation.where(assignable_type: "Team").update_all(assignee_id: nil)
            remove_index :investigations, %i[assignable_type assignee_id]
            add_index :investigations, :assignee_id
          end
        end
      end
    end
  end
end
