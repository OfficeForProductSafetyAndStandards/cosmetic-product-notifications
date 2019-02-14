class StorePrettyIdInInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          t.string :pretty_id

          dir.up do
            Investigation.all.each do |investigation|
              investigation.update! pretty_id: investigation.add_pretty_id
            end
            add_index :investigations, :pretty_id
          end
        end
      end
    end
  end
end
