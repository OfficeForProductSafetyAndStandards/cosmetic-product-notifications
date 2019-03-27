class Location < ApplicationRecord
  include Shared::Web::CountriesHelper

  default_scope { order(created_at: :asc) }

  validates :name, presence: true

  belongs_to :business

  has_one :source, as: :sourceable, dependent: :destroy

  def summary
    [
      address_line_1,
      address_line_2,
      postal_code,
      country_from_code(country)
    ].reject(&:blank?).join(", ")
  end

  def short
    [
      county,
      country_from_code(country)
    ].reject(&:blank?).join(", ")
  end
end
