class Business < ApplicationRecord
  include Searchable

  index_name [Rails.env, "businesses"].join("_")

  settings do
    mappings do
      indexes :company_number, type: :keyword
      indexes :company_type_code, type: :keyword, fields: { sort: { type: "keyword" } }
      indexes :company_status_code, type: :keyword, fields: { sort: { type: "keyword" } }
    end
  end

  validates :company_name, presence: true
  default_scope { order(created_at: :desc) }
  has_many :investigation_businesses, dependent: :destroy
  has_many :investigations, through: :investigation_businesses
  has_many :addresses, dependent: :destroy
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source
  accepts_nested_attributes_for :addresses, reject_if: :all_blank

  has_paper_trail

  def nature_of_business
    Rails.application.config.companies_house_constants["sic_descriptions"][nature_of_business_id]
  end

  def company_type
    Rails.application.config.companies_house_constants["company_type"][company_type_code]
  end

  def company_status
    Rails.application.config.companies_house_constants["company_status"][company_status_code]
  end

  def from_companies_house?
    !company_number.nil?
  end

  def primary_address
    addresses.first
  end
end

Business.import force: true # for auto sync model with elastic search
