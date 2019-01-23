class UpdateProductsSchema < ActiveRecord::Migration[5.2]
  class Product < ApplicationRecord; end
  def change
    safety_assured do # rubocop:disable Metrics/BlockLength
      reversible do |dir|
        dir.up do
          change_table :products, bulk: true do |t|
            t.rename :gtin, :product_code

            t.rename :product_type, :category
            t.string :product_type

            t.string :webpage

            Product.in_batches.each_record do |product|
              product.update! name: [product.brand, product.name, product.model].reject(&:nil?).join(", ")
            end

            t.remove :brand
            t.remove :model
          end

          rename_column :investigations, :product_type, :product_category
        end


        dir.down do
          change_table :products, bulk: true do |t|
            t.rename :product_code, :gtin

            t.remove :product_type
            t.rename :category, :product_type

            t.remove :webpage

            t.string :brand
            t.string :model
          end

          rename_column :investigations, :product_category, :product_type
        end
      end
    end
  end
end
