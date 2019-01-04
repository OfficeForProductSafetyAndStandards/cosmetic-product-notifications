class AddNanomaterialsToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_reference :nanomaterials, :component, index: false, foreign_key: true
    add_index :nanomaterials, :component_id, algorithm: :concurrently
  end
end
