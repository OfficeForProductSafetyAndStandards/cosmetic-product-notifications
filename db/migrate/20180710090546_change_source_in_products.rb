class ChangeSourceInProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :source, :string
    add_reference :products, :source, type: :uuid, foreign_key: true
  end
end
