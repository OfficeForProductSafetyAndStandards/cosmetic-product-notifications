module NanoMaterialsHelper
  def nano_elements
    {
        titanium: {iupac_name: "Titanium dioxide"},
        triazine: {iupac_name: "Tris-biphenyl triazine"},
        carbon: {iupac_name: "Carbon black"},
        other: {iupac_name: "Other"}
    }
  end

  def nano_elements_label
    {
        titanium: "This product contains Titanium dioxide as a UV filter",
        triazine: "This product contains Tris-biphenyl triazine as a UV filter",
        carbon: "This product contains Carbon black as a colorant",
        other: "Other"
    }
  end

  def exposure_routes
    %w(Dermal Oral Inhalation)
  end

  def exposure_conditions
    ["Rinse off", "Leave on"]
  end
end
