class AddPurposesToNanoElements < ActiveRecord::Migration[5.2]
  def change
    add_column :nano_elements, :purposes, :string, array: true
  end
end
