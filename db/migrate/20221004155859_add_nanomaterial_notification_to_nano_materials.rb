class AddNanomaterialNotificationToNanoMaterials < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :nano_materials, :nanomaterial_notification, null: true, index: { algorithm: :concurrently }
  end
end
