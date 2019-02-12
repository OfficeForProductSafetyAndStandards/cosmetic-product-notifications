class StorePrettyIdInInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          t.string :pretty_id

          dir.up do
            id = 0
            Investigation.all.order(updated_at: :asc).each do |investigation|
              investigation.update! pretty_id: Investigation.next_pretty_id(id: id)
              id += 1
            end
            add_index :investigations, :pretty_id
          end
        end
      end
    end
  end
end
