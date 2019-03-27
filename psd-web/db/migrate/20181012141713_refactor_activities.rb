class RefactorActivities < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :activities do |t|
          dir.up do
            t.rename :notes, :description
            t.string :type, default: "CommentActivity"
            t.remove :activity_type
          end

          dir.down do
            t.rename :description, :notes
            t.remove :type
            t.integer :activity_type, null: false, default: 0
          end
        end
      end
    end
  end
end
