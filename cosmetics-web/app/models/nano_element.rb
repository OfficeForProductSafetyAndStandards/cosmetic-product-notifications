class NanoElement < ApplicationRecord
  YES = "yes".freeze
  NO = "no".freeze
  NOT_SURE = "not sure".freeze

  belongs_to :nano_material

  # TODO: add uniqueness validation across notifications
  validates :inci_name, presence: true, on: :add_nanomaterial_name
  validate :unique_name_per_nanomaterial, on: :add_nanomaterial_name

  after_save do
    if blocked?
      notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
    end
  end

  validates :purposes, presence: true, on: :select_purposes
  validates :purposes, array: { presence: true, inclusion: { in: NanoElementPurposes.all.map(&:name) } }

  def display_name
    [iupac_name, inci_name, inn_name, xan_name, cas_number, ec_number, einecs_number, elincs_number]
      .reject(&:blank?).join(", ")
  end

  def required?
    purposes.blank? ||
      (non_standard? && toxicology_required_or_empty?) ||
      (standard? && restrictions_confirmed_required?)
  end

  def standard?
    purposes.present? && !non_standard?
  end

  def non_standard?
    purposes.present? && purposes.include?(NanoElementPurposes.other.name)
  end

  def multi_purpose?
    purposes.count > 1
  end

  def completed?
    ((standard? && inci_name.present? && confirm_usage == YES && confirm_restrictions == YES) ||
      (non_standard? && confirm_toxicology_notified == YES)) && !blocked?
  end

  def blocked?
    confirm_usage == NO ||
      confirm_restrictions == NO ||
      confirm_toxicology_notified == NO ||
      confirm_toxicology_notified == NOT_SURE
  end

  def toxicology_required?
    non_standard? && (confirm_toxicology_notified == NOT_SURE || confirm_toxicology_notified == NO)
  end

  def toxicology_required_or_empty?
    confirm_toxicology_notified.nil? || toxicology_required?
  end

  def conforms_to_restrictions?
    (confirm_restrictions != NO && confirm_usage != NO) && !toxicology_required_or_empty?
  end

private

  def restrictions_confirmed_required?
    confirm_restrictions.nil? ||
      (confirm_restrictions == NO) ||
      ((confirm_restrictions == YES && usage_confirmed_required?) ||
       (confirm_usage == NO && toxicology_required_or_empty?))
  end

  def usage_confirmed_required?
    confirm_usage.nil?
  end

  def notification
    nano_material.notification
  end

  def unique_name_per_nanomaterial
    nano_elements_with_same_name = NanoElement.where(nano_material: nano_material.notification.nano_materials)
                                              .where.not(id:)
                                              .where("trim(lower(inci_name)) = ?", inci_name.downcase.strip)
    if nano_elements_with_same_name.any?
      errors.add(:inci_name)
    end
  end
end
