class NanoElement < ApplicationRecord
  belongs_to :nano_material

  def display_name
    [iupac_name, inci_name, inn_name, xan_name, cas_number, ec_number, einecs_number, elincs_number]
        .join(', ')
  end
end
