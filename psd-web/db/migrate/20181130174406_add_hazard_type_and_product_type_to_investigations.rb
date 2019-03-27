class AddHazardTypeAndProductTypeToInvestigations < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :investigations, bulk: true do |t|
        t.string :hazard_type, :product_type
      end
    end
  end
end
