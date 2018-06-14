class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products, id: :uuid do |t|
      t.string :gtin
      t.string :name
      t.text :description
      t.string :model
      t.string :mpn
      t.string :batch_number
      t.string :purchase_url
      t.string :brand

      t.timestamps
    end
  end
end
