class AddProductIdToActivities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :activities, :product, index: false, foreign_key: true
    add_index :activities, :product_id, algorithm: :concurrently
  end
end
