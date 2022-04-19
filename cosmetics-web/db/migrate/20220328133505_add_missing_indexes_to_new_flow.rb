class AddMissingIndexesToNewFlow < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :nano_materials, :notification_id, algorithm: :concurrently
    add_index :component_nano_materials, :component_id, algorithm: :concurrently
    add_index :component_nano_materials, :nano_material_id, algorithm: :concurrently
  end
end
