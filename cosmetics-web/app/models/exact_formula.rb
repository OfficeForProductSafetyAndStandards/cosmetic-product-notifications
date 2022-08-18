class ExactFormula < ApplicationRecord
  include CasNumberConcern

  belongs_to :component

  validates :inci_name, presence: true
  validates :quantity, presence: true

  def display_name
    "#{inci_name}: #{quantity}"
  end

  def self.for_list(order: nil)
    query = select("DISTINCT (inci_name)")
    case order
    when "date"
      select("exact_formulas.*").joins("LEFT JOIN exact_formulas f2 on exact_formulas.inci_name = f2.inci_name AND exact_formulas.created_at > f2.created_at").where("f2.id IS NULL")
    when "name_desc"
      query.order("inci_name DESC")
    else
      query.order("inci_name")
    end
  end
end
