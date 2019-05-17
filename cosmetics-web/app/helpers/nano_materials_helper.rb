module NanoMaterialsHelper
  def nano_elements_purposes
    {
        colorant: "Colorant",
        preservative: "Preservative",
        uv_filter: "UV filter",
        other: "Another purpose"
    }
  end

  def ec_regulation_annex_number
    {
        colorant: 4,
        preservative: 5,
        uv_filter: 6
    }
  end

  def exposure_routes_symbols
    %i(dermal oral inhalation)
  end
end
