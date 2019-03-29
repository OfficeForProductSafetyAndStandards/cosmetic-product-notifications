class AddNanoMaterialsToComponent < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :nano_materials do |t|
      t.string :exposure_condition
      t.string :exposure_route

      t.timestamps
    end

    add_reference :nano_materials, :component, foreign_key: true, index: false
    add_index :nano_materials, :component_id, algorithm: :concurrently

    create_table :nano_elements do |t|
      t.string :inci_name
      t.string :inn_name
      t.string :iupac_name
      t.string :xan_name
      t.string :cas_number
      t.string :ec_number
      t.string :einecs_number
      t.string :elincs_number

      t.timestamps
    end

    add_reference :nano_elements, :nano_material, foreign_key: true, index: false
    add_index :nano_elements, :nano_material_id, algorithm: :concurrently
  end
end
