module FormulaHelper
  def format_exact_formulas(exact_formulas)
    exact_formulas.collect { |formula| { inci_name: formula[:inci_name], quantity: display_concentration(formula[:quantity]) } }
  end

  def format_range_formulas(range_formulas)
    range_formulas.collect { |formula| { inci_name: formula[:inci_name], range: display_concentration_range(formula[:range]) } }
  end
end
