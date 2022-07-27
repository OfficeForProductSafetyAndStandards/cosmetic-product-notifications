class CreateIngredient < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      create_enum :concentration_range,
                  %w[less_than_01_percent
                     greater_than_01_less_than_1_percent
                     greater_than_1_less_than_5_percent
                     greater_than_5_less_than_10_percent
                     greater_than_10_less_than_25_percent
                     greater_than_25_less_than_50_percent
                     greater_than_50_less_than_75_percent
                     greater_than_75_less_than_100_percent]

      create_table :ingredients do |t|
        t.string "inci_name", null: false
        t.string "cas_number"
        t.decimal "exact_concentration"
        t.enum "range_concentration", as: "concentration_range"
        t.boolean "poisonous", default: false, null: false

        t.timestamps
      end

      add_reference :ingredients, :component, foreign_key: true, index: true
    end
  end
end
