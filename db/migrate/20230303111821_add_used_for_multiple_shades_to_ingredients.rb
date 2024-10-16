class AddUsedForMultipleShadesToIngredients < ActiveRecord::Migration[7.0]
  def change
    add_column :ingredients, :used_for_multiple_shades, :boolean
  end
end
