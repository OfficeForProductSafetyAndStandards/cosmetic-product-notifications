class AddMinimumAndMaximumConcentrationToIngredients < ActiveRecord::Migration[7.0]
  def change
    add_column :ingredients, :minimum_concentration, :decimal, index: true
    add_column :ingredients, :maximum_concentration, :decimal, index: true
  end
end
