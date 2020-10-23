class NanoElement < ApplicationRecord
  belongs_to :nano_material

  def self.purposes
    %w[colorant preservative uv_filter other].freeze
  end

  validates :purposes, presence: true, on: :select_purposes
  validates :purposes, array: { presence: true, inclusion: { in: NanoElement.purposes } }

  def display_name
    [iupac_name, inci_name, inn_name, xan_name, cas_number, ec_number, einecs_number, elincs_number]
      .reject(&:blank?).join(", ")
  end

  def required?
    purposes.blank? ||
      (non_standard? && toxicology_required?) ||
      (standard? && restrictions_confirmed_required?)
  end

  def standard?
    !non_standard?
  end

  def non_standard?
    purposes.present? && purposes.include?("other")
  end

private

  def toxicology_required?
    confirm_toxicology_notified.nil? ||
      confirm_toxicology_notified == "not sure" ||
      confirm_toxicology_notified == "no"
  end

  def restrictions_confirmed_required?
    confirm_restrictions.nil? ||
      (confirm_restrictions == "no" && toxicology_required?) ||
      (
        (confirm_restrictions == "yes" && usage_confirmed_required?) ||
       (confirm_usage == "no" && toxicology_required?)
      )
  end

  def usage_confirmed_required?
    confirm_usage.nil?
  end
end
