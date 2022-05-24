class ChangeNullableAttributesOnExactFormulas < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :exact_formulas, "inci_name IS NOT NULL", name: "exact_formulas_inci_name_null", validate: false
    add_check_constraint :exact_formulas, "quantity IS NOT NULL", name: "exact_formulas_quantity_null", validate: false
  end
end
