class ValidateChangeNullableAttributesOnExactFormulas < ActiveRecord::Migration[6.1]
  def change
    validate_check_constraint :exact_formulas, name: "exact_formulas_inci_name_null"
    validate_check_constraint :exact_formulas, name: "exact_formulas_quantity_null"

    change_column_null :exact_formulas, :inci_name, false
    change_column_null :exact_formulas, :quantity, false

    remove_check_constraint :exact_formulas, name: "exact_formulas_inci_name_null"
    remove_check_constraint :exact_formulas, name: "exact_formulas_quantity_null"
  end
end
