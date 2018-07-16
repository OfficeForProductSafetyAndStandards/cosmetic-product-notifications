class RemoveSourceFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :source, :string
  end
end
