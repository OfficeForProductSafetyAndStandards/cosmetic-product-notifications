class CreatePotentialProductDuplicates < ActiveRecord::Migration[5.2]
  def change
    create_table :potential_product_duplicates do |t|
      t.references :product, index: true, foreign_key: true, type: :uuid
      t.references :duplicate_product, index: true, type: :uuid
      t.decimal :score
    end

    add_foreign_key :potential_product_duplicates, :products, column: :duplicate_product_id
    add_index :potential_product_duplicates, %i[product_id duplicate_product_id], unique: true,
      name: "index_on_product_id_and_duplicate_product_id"
  end
end
