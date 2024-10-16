class ValidateAddForeignKeyToNanoMaterials < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :nano_materials, :nanomaterial_notifications
  end
end
