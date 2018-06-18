class CreateRapexImports < ActiveRecord::Migration[5.2]
  def change
    create_table :rapex_imports do |t|
      t.string :reference, null: false

      t.timestamps
    end
  end
end
