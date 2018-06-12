class AddImageUrlToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :image_url, :string
  end
end
