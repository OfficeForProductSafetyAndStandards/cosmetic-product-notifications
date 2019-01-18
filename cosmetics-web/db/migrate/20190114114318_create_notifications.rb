class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :product_name
      t.string :external_reference
      t.integer :state

      t.timestamps
    end
  end
end
