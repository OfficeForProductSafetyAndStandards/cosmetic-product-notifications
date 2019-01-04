class AddCmrMaterialsToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_reference :cmr_materials, :component, index: false, foreign_key: true
    add_index :cmr_materials, :component_id, algorithm: :concurrently
  end
end
