class CreateFormulaFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :formula_files do |t|
      t.string :filepath

      t.timestamps
    end
  end
end
