class NanoElement < ApplicationRecord
  belongs_to :nano_material

  def display_name
    [iupac_name, inci_name, inn_name, xan_name, cas_number, ec_number, einecs_number, elincs_number]
      .reject(&:blank?).join(', ')
  end

  def self.purpose_options
    {
      colorant: "Colourant",
      preservative: "Preservative",
      uv_filter: "UV filter",
      other: "Another purpose"
    }.freeze
  end
end
