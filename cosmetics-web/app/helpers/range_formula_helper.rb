module RangeFormulaHelper
  def format_range_formulas(range_formulas)
    range_formulas.collect { |formula| { inci_name: formula[:inci_name], range: "#{get_unit_name(formula[:range])} %w/w" } }
  end
end
