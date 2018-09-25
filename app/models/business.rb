class Business < ApplicationRecord
  include BusinessesHelper
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
    companies_house_constants["sic_descriptions"][nature_of_business_id]
  end

  def company_type
    companies_house_constants["company_type"][company_type_code]
  end

  def company_status
    companies_house_constants["company_status"][company_status_code]
  end

  def from_companies_house?
    !company_number.nil?
  end

  def primary_address
    addresses.first
  end

  def self.from_companies_house_response(response)
    Business.new.with_company_house_info(response)
  end

  def with_company_house_info(c_h_info)
    self.company_number = c_h_info["company_number"]
    self.company_name = c_h_info["company_name"]
    self.company_type_code = c_h_info["type"]
    self.company_status_code = c_h_info["company_status"]
    self.source ||= ReportSource.new(name: "Companies House")
    add_sic_code(c_h_info)
    save

    registered_office = c_h_info["registered_office_address"]
    add_registered_address(registered_office) unless registered_office.nil?
    self
  end

private

  def add_sic_code(c_h_info)
    self.nature_of_business_id = c_h_info["sic_codes"][0] if c_h_info["sic_codes"].present?
  end

  def add_registered_address(registered_office)
    registered_office_address = primary_address || addresses.build
    registered_office_address.with_registered_office_info(registered_office)
  end
end

Business.import force: true # for auto sync model with elastic search
