class AddCasNumberAndPoisonousToExactFormulas < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :exact_formulas, bulk: true do |t|
        t.string :cas_number
        t.boolean :poisonous, default: false, null: false
      end
    end
  end
end
