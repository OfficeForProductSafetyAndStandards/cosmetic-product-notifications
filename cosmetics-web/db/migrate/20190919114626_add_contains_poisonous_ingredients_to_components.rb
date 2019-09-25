class AddContainsPoisonousIngredientsToComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :components, :contains_poisonous_ingredients, :boolean
  end
end
