class AddForeignKeyToNanoMaterials < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :nano_materials, :nanomaterial_notifications, validate: false
  end
end
