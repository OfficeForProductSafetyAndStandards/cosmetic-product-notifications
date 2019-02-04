class AddTeamAssigneeToInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          t.uuid :assignable_id
          t.string :assignable_type

          dir.up do
            Investigation.all.each do |investigation|
              investigation.update! assignable_type: investigation.assignee_id.present? ? "User" : ""
              investigation.update! assignable_id: investigation.assignee_id
            end
            t.remove :assignee_id
            add_index :investigations, %i[assignable_type assignable_id]
          end

          dir.down do
            t.uuid :assignee_id
            Investigation.all.each do |investigation|
              investigation.update! assignee_id: investigation.assignable_id
            end
            add_index :investigations, :assignee_id
          end
        end
      end
    end
  end
end
