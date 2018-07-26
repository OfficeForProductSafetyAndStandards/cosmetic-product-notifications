require "elasticsearch/model"

class Business < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.env, "businesses"].join("_")

  validates :company_name, presence: true
  default_scope { order(created_at: :desc) }
  has_many :investigation_businesses, dependent: :destroy
  has_many :investigations, through: :investigation_businesses
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail

  def nature_of_business
    Rails.application.config.companies_house_constants["sic_descriptions"][nature_of_business_id]
  end

  def company_type
    Rails.application.config.companies_house_constants["company_type"][company_type_code]
  end

  def address_summary
    [
      registered_office_address_line_1,
      registered_office_address_postal_code,
      registered_office_address_country
    ].join(", ")
  end
end

Business.import force: true # for auto sync model with elastic search