class RemovePriorityFromInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          dir.up do
            t.remove :priority
          end

          dir.down do
            t.integer :priority
          end
        end
      end
    end
    Activity.where(type: "AuditActivity::Investigation::UpdatePriority").delete_all
  end
end
