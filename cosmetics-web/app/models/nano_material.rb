class NanoMaterial < ApplicationRecord
  PURPOSES = %w[colorant preservative uv_filter other].freeze

  belongs_to :notification, optional: false

  has_many :component_nano_materials, dependent: :destroy
  has_many :components, through: :component_nano_materials

  delegate :component_name, to: :component

  validates :inci_name, presence: true, on: :add_nanomaterial_name
  validate :unique_name_per_notification, on: :add_nanomaterial_name
  validates :purposes, presence: true, on: :select_purposes
  validates :purposes, array: { presence: true, inclusion: { in: PURPOSES } }

  after_save do
    if blocked?
      notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
    end
  end

  def self.purposes
    PURPOSES
  end

  def display_name
    [iupac_name, inci_name, inn_name, xan_name, cas_number, ec_number, einecs_number, elincs_number]
      .reject(&:blank?).join(", ")
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
    purposes&.include?("other") && (confirm_toxicology_notified == "not sure" || confirm_toxicology_notified == "no")
  end

  def conforms_to_restrictions?
    confirm_restrictions != "no" && confirm_usage != "no" && !toxicology_required_or_empty?
  end

  def name
    inci_name
  end

private

  def toxicology_required_or_empty?
    confirm_toxicology_notified.blank? || toxicology_required?
  end

  def unique_name_per_notification
    nanos_with_same_name = self.class.where(notification:)
                                     .where.not(id:)
                                     .where("trim(lower(inci_name)) = ?", inci_name.downcase.strip)
    errors.add(:inci_name) if nanos_with_same_name.any?
  end
end
