class AddProductTypeToProducts < ActiveRecord::Migration[5.2]
  def change
    # "type" is a reserved keyword so it is prefixed with product_
    add_column :products, :product_type, :string
  end
end
