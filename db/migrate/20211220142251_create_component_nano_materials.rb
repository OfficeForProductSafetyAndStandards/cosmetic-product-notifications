class CreateComponentNanoMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :component_nano_materials do |t|
      t.integer :component_id
      t.integer :nano_material_id

      t.timestamps
    end
  end
end
