class BackfillUsedForMultipleShadesForIngredients < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    affected_ingredients = Ingredient.joins(:component)
      .where.not(exact_concentration: nil)
      .where(used_for_multiple_shades: nil)
      .where.not(component: { shades: [nil] })
      .where.not(component: { shades: [""] })
    affected_ingredients.in_batches do |ingredients|
      ingredients.update_all(used_for_multiple_shades: false)
      sleep(0.01) # throttle
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
