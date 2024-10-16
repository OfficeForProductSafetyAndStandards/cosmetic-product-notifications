class AddMinimumMaximumConcentrationsToIngredients < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :ingredients, bulk: true do |t|
        t.decimal :minimum_concentration
        t.decimal :maximum_concentration
      end
    end
  end
end
