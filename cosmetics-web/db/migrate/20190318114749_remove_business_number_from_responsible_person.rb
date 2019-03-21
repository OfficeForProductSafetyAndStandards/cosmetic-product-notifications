class RemoveBusinessNumberFromResponsiblePerson < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :responsible_persons do |t|
          dir.up do
            t.remove :companies_house_number
          end

          dir.down do
            t.string :companies_house_number
          end
        end
      end
    end
  end
end
