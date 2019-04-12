module ConcentrationHelper
  def display_concentration(concentration)
    if concentration.to_s.split('.').last.size > 2
      "#{concentration}% w/w"
    else
      "#{number_with_precision(concentration, precision: 2)}% w/w"
    end
  end

  def display_concentration_range(range)
    "#{get_unit_name(range)}% w/w"
  end
end
