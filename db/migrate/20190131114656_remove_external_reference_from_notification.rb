class RemoveExternalReferenceFromNotification < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :notifications do |t|
          dir.up do
            t.remove :external_reference
          end

          dir.down do
            t.string :external_reference
          end
        end
      end
    end
  end
end
