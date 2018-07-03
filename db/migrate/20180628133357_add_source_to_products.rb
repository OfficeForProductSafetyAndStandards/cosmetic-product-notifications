class AddSourceToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :source, :string
  end
end
