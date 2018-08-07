class ChangeProductDataStructure < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :image_url, :string
    remove_column :products, :mpn, :string
    rename_column :products, :purchase_url, :url_reference

    add_column :products, :serial_number, :string
    add_column :products, :manufacturer, :string
    add_column :products, :country_of_origin, :string
    add_column :products, :date_placed_on_market, :datetime
    add_column :products, :associated_parts, :string
  end
end
