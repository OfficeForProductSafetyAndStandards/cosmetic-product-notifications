class NanoElement < ApplicationRecord
  belongs_to :nano_material

  # TODO: add uniquenes notification across notifications
  validates :inci_name, presence: true, on: :add_nanomaterial_name

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
    purposes.present? && !non_standard?
  end

  def non_standard?
    purposes.present? && purposes.include?("other")
  end

  def multi_purpose?
    purposes.count > 1
  end

  def completed?
    ((standard? && inci_name.present? && confirm_usage == "yes" && confirm_restrictions == "yes") ||
      (purposes&.include?("other") && confirm_toxicology_notified == "yes")) && !blocked?
  end

  def blocked?
    confirm_usage == "no" || confirm_restrictions == "no" || confirm_toxicology_notified == "no" || confirm_toxicology_notified == "not sure"
  end

  def toxicology_required?
    confirm_toxicology_notified.nil? ||
      confirm_toxicology_notified == "not sure" ||
      confirm_toxicology_notified == "no"
  end

  def conforms_to_restrictions?
    confirm_restrictions != "no" && confirm_usage != "no"
  end

private

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
