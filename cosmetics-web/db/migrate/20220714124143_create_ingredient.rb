class CreateIngredient < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      create_enum :ingredient_range_concentration,
                  %w[less_than_01_percent
                     greater_than_01_less_than_1_percent
                     greater_than_1_less_than_5_percent
                     greater_than_5_less_than_10_percent
                     greater_than_10_less_than_25_percent
                     greater_than_25_less_than_50_percent
                     greater_than_50_less_than_75_percent
                     greater_than_75_less_than_100_percent]

      create_table :ingredients do |t|
        t.citext "inci_name", null: false
        t.string "cas_number"
        t.decimal "exact_concentration"
        t.enum "range_concentration", enum_type: "ingredient_range_concentration"
        t.boolean "poisonous", default: false, null: false

        t.timestamps
      end

      add_reference :ingredients, :component, foreign_key: true, index: false
      add_index :ingredients, :component_id, algorithm: :concurrently
      add_index :ingredients, :inci_name, algorithm: :concurrently
      add_index :ingredients, :poisonous, algorithm: :concurrently
      add_index :ingredients, :range_concentration, algorithm: :concurrently
      add_index :ingredients, :exact_concentration, algorithm: :concurrently
      add_index :ingredients, :created_at, algorithm: :concurrently
    end
  end
end
