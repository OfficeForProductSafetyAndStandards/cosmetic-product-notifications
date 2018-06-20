class RemoveProductIdFromInvestigations < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :investigations, :products
    remove_index :investigations, :product_id
    remove_column :investigations, :product_id
  end
end
