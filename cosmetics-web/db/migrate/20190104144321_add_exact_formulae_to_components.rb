class AddExactFormulaeToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_reference :exact_formulas, :component, index: false, foreign_key: true
    add_index :exact_formulas, :component_id, algorithm: :concurrently
  end
end
