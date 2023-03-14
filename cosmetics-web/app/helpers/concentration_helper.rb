module ConcentrationHelper
  def display_concentration(concentration, used_for_multiple_shades: false)
    prefix = "Maximum concentration: " if used_for_multiple_shades
    if concentration.to_s.split(".").last.size > 2
      "#{prefix}#{concentration}%&nbsp;w/w".html_safe
    else
      "#{prefix}#{number_with_precision(concentration, precision: 2)}%&nbsp;w/w".html_safe
    end
  end

  def display_concentration_range(range)
    "#{get_unit_name(range)}%&nbsp;w/w".html_safe
  end
end
