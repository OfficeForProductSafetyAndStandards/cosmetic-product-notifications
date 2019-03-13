module NanoMaterialsHelper
  # def create_nano_element(nano_element_id)
  #   get_nano_elements[nano_element_id]
  # end

  def nano_materials
    [
        {iupac_name: "Titanium dioxide"},
        {iupac_name: "Zinc oxide"},
        {iupac_name: "Tris-biphenyl triazine"},
        {iupac_name: "Carbon black"},
        {iupac_name: "Other"}
    ]
  end

  def exposure_routes
    %w(Dermal Oral Inhalation)
  end

  def exposure_conditions
    ["Rinse off", "Leave on"]
  end
end
