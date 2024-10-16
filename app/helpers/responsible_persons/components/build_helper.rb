module ResponsiblePersons::Components::BuildHelper
  def ingredients_csv_column_reference_for(attribute, range_notification:)
    case attribute
    when :inci_name
      "A"
    when :exact_concentration, :maximum_exact_concentration
      range_notification ? "D" : "B"
    when :cas_number
      range_notification ? "E" : "C"
    when :poisonous
      range_notification ? "F" : "D"
    when :used_for_multiple_shades
      "E"
    when :minimum_concentration
      "B"
    when :maximum_concentration
      "C"
    else
      ""
    end
  end
end
