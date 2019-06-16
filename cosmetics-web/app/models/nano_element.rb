class NanoElement < ApplicationRecord
  belongs_to :nano_material

  validates :purposes, presence: true, on: :select_purpose
  validates :purposes, array: { presence: true, inclusion: { in: %w(colorant preservative uv_filter other) } }

  def display_name
    [iupac_name, inci_name, inn_name, xan_name, cas_number, ec_number, einecs_number, elincs_number]
      .reject(&:blank?).join(', ')
  end

  def non_standard?
    purposes.present? && purposes.include?("other")
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
