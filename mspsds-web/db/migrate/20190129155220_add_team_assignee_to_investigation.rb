class AddTeamAssigneeToInvestigation < ActiveRecord::Migration[5.2]
  safety_assured do
    change_table :investigations, bulk: true do |t|
      t.uuid :assignable_id
      t.string  :assignable_type
    end

    add_index :investigations, [:assignable_type, :assignable_id]
  end
end
