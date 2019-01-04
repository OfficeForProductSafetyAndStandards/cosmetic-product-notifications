class AddFormulaFileToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_reference :formula_files, :component, index: false, foreign_key: true
    add_index :formula_files, :component_id, algorithm: :concurrently, :unique => true
  end
end
