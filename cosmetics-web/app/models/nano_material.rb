class NanoMaterial < ApplicationRecord
  include Clonable

  PURPOSES = %w[colorant preservative uv_filter other].freeze
  YES = "yes".freeze
  NO = "no".freeze
  NOT_SURE = "not sure".freeze

  belongs_to :nanomaterial_notification, optional: true
  belongs_to :notification, optional: false

  has_many :component_nano_materials, dependent: :destroy
  has_many :components, through: :component_nano_materials

  delegate :component_name, to: :component

  validates :inci_name, presence: true, on: :add_nanomaterial_name
  validate :unique_name_per_product_notification, on: :add_nanomaterial_name
  validate :nanomaterial_notification_association
  validates :nanomaterial_notification, uniqueness: { scope: :notification_id, allow_blank: true }
  validates :purposes, presence: true, on: :select_purposes
  validates :purposes, array: { presence: true, inclusion: { in: NanoMaterialPurposes.all.map(&:name) } }

  after_save do
    if blocked?
      notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
    end
  end

  class << self
    def standard
      where.not(purposes: [nil, ""]).where.not(purposes: [NanoMaterialPurposes.other.name])
    end

    def non_standard
      where(purposes: [NanoMaterialPurposes.other.name])
    end
  end

  def display_name
    [iupac_name,
     inci_name,
     nanomaterial_notification&.name,
     inn_name,
     xan_name,
     cas_number,
     ec_number,
     einecs_number,
     elincs_number].reject(&:blank?).join(", ")
  end

  def standard?
    purposes.present? && !non_standard?
  end

  def non_standard?
    purposes.present? && purposes.include?(NanoMaterialPurposes.other.name)
  end

  def multi_purpose?
    purposes.count > 1
  end

  def completed?
    (standard_completed? || non_standard_completed?) && !blocked?
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

  def conforms_to_restrictions?
    (confirm_restrictions != NO && confirm_usage != NO) && !toxicology_required_or_empty?
  end

  def name
    inci_name.presence || nanomaterial_notification&.name
  end

private

  def standard_completed?
    standard? && inci_name.present? && confirm_usage == YES && confirm_restrictions == YES
  end

  def non_standard_completed?
    non_standard? && confirm_toxicology_notified == YES && nanomaterial_notification.present?
  end

  def toxicology_required_or_empty?
    confirm_toxicology_notified.blank? || toxicology_required?
  end

  def unique_name_per_product_notification
    nanos_with_same_name = self.class.where(notification:)
                                     .where.not(id:)
                                     .where("trim(lower(inci_name)) = ?", inci_name.downcase.strip)
    errors.add(:inci_name) if nanos_with_same_name.any?
  end

  def nanomaterial_notification_association
    return if nanomaterial_notification.blank?

    errors.add(:nanomaterial_notification, :standard) if standard?
    if notification && nanomaterial_notification.responsible_person != notification.responsible_person
      errors.add(:nanomaterial_notification, :wrong_responsible_person)
    end
  end
end
