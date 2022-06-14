module ComponentBuildHelper
  def cmr_errors(component)
    component.cmrs.each_with_index.flat_map { |cmr, index| cmr.errors.map { |error| { text: error.message, href: "#component_cmrs_attributes_#{index}_#{error.attribute}" } } } +
      component.errors.reject { |error| error.attribute.to_s.include? "cmrs." }.map { |error| { text: error.message, href: "#component_cmrs_attributes_0_name" } }
  end

  def ingredient_range_concentration_html_for(above, up_to)
    "Above <span class='govuk-!-font-weight-bold'>#{above}%</span> " \
    "<abbr class='govuk-!-font-size-16' title='Weight by weight'>w/w</abbr> " \
    "up to <span class='govuk-!-font-weight-bold'>#{up_to}%</span> " \
    "<abbr class='govuk-!-font-size-16'>w/w</abbr>"
  end

  def ingredient_range_concentration_item(above, up_to)
    {
      html: ingredient_range_concentration_html_for(above, up_to).html_safe,
      value: "greater_than_#{above}_less_than_#{up_to}_percent",
      id: "greater_than_#{above}_less_than_#{up_to}_percent",
    }
  end

  def ingredient_range_concentration_items
    [
      ingredient_range_concentration_item("75", "100"),
      ingredient_range_concentration_item("50", "75"),
      ingredient_range_concentration_item("25", "50"),
      ingredient_range_concentration_item("10", "25"),
      ingredient_range_concentration_item("5", "10"),
      ingredient_range_concentration_item("1", "5"),
      ingredient_range_concentration_item("0.1", "1"),
      {
        html: "Up to and including <span class='govuk-!-font-weight-bold'>0.1%</span> <abbr class='govuk-!-font-size-16'>w/w</abbr>".html_safe,
        value: "less_than_01_percent",
        id: "less_than_01_percent",
      },
    ]
  end
end
