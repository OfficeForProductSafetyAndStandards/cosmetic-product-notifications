class RemoveExposureAttrsFromNanoMaterials < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      change_table :nano_materials, bulk: true do |t|
        t.remove :exposure_condition
        t.remove :exposure_routes
      end
    end
  end

  def down
    safety_assured do
      change_table :nano_materials, bulk: true do |t|
        t.string :exposure_condition
        t.string :exposure_routes, array: true
      end
    end
  end
end
