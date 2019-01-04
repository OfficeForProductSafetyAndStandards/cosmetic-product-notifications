class CreateCmrMaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :cmr_materials do |t|
      t.string :name
      t.string :cas_registry_number

      t.timestamps
    end
  end
end
