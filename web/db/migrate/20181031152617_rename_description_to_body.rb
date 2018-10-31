class RenameDescriptionToBody < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :activities do |t|
          dir.up do
            t.rename :description, :body
          end

          dir.down do
            t.rename :body, :description
          end
        end
      end
    end
  end
end
