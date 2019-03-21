class PopulateAssigneeAndDescription < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :investigations, :assignable_type
      Investigation.all.each do |i|
        i.description = i.description || i.reason_created
        i.assignee = i.assignee || i.source.user
        i.save
      end
      add_index :investigations, :assignable_id
    end
  end
end
