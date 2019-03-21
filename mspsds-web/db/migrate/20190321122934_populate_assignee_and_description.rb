class PopulateAssigneeAndDescription < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          dir.up do
            t.remove :assignable_type
            Investigation.all.each do |i|
              i.description = i.description || i.reason_created
              i.assignee = i.assignee || i.source.user
              i.save
            end
            add_index :investigations, :assignable_id
          end
          dir.down do
            t.string :assignable_type
            add_index :investigations, %i[assignable_id assignable_type]
          end
        end
      end
    end
  end
end
