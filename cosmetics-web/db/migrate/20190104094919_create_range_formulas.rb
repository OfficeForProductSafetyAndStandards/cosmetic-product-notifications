class CreateRangeFormulas < ActiveRecord::Migration[5.2]
  def change
    create_table :range_formulas do |t|
      t.string :inci_name
      t.integer :range

      t.timestamps
    end
  end
end
