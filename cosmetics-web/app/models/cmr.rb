class Cmr < ApplicationRecord
  belongs_to :component

  CMR_NUMBER_REGEX = /\A(\d+-)*\d+\z/.freeze

  validates :name, presence: true
  validates :cas_number, format: { with: CMR_NUMBER_REGEX }, allow_blank: true
  validates :ec_number, format: { with: CMR_NUMBER_REGEX }, allow_blank: true

  before_save :remove_hyphens
  def display_name
    [name, ec_number, cas_number].reject(&:blank?).join(', ')
  end

private

  def remove_hyphens
    cas_number.delete!("-")
    ec_number.delete!("-")
  end
end
