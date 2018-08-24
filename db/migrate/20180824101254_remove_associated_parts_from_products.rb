class RemoveAssociatedPartsFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :associated_parts, :string
    remove_column :products, :serial_number, :string
    remove_column :products, :manufacturer, :string
    remove_column :products, :url_reference, :string
  end
end
