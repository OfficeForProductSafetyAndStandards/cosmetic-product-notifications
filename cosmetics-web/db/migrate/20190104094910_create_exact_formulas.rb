class CreateExactFormulas < ActiveRecord::Migration[5.2]
  def change
    create_table :exact_formulas do |t|
      t.string :inci_name
      t.integer :quantity

      t.timestamps
    end
  end
end
