class UpdateProductsSchema < ActiveRecord::Migration[5.2]
  class Product < ApplicationRecord; end
  def change
    safety_assured do
      change_table :products do |t|
        reversible do |dir|
          dir.up do
            t.rename :gtin, :product_code

            t.rename :product_type, :category
            t.string :product_type

            t.string :webpage

            Product.all.each do |product|
              product.update! name: "#{product.brand}, #{product.name}, #{product.model}"
            end

            t.remove :brand
            t.remove :model
          end

          dir.down do
            t.rename :product_code, :gtin

            t.rename :category, :product_type
            t.remove :category

            t.remove :webpage

            t.string :brand
            t.string :model
          end
        end
      end
    end
  end
end
