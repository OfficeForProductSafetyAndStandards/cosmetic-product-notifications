class AddNanoElementsAttrsToNanoMaterials < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :nano_materials, bulk: true do |t|
        t.string :inci_name
        t.string :inn_name
        t.string :iupac_name
        t.string :xan_name
        t.string :cas_number
        t.string :ec_number
        t.string :einecs_number
        t.string :elincs_number
        t.string :purposes, array: true
        t.string :confirm_toxicology_notified
        t.string :confirm_usage
        t.string :confirm_restrictions
      end
    end
  end
end
