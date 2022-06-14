class AddCasNumberToRangeFormulas < ActiveRecord::Migration[6.1]
  def change
    add_column :range_formulas, :cas_number, :string
  end
end
