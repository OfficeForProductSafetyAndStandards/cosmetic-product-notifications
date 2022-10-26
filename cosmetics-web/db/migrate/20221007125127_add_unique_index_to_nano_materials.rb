class AddUniqueIndexToNanoMaterials < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index(:nano_materials,
              %i[notification_id nanomaterial_notification_id],
              unique: true,
              algorithm: :concurrently,
              name: "index_nano_materials_on_notification_and_nano_notification")
  end
end
