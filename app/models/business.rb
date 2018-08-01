require "elasticsearch/model"

class Business < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.env, "businesses"].join("_")

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

  def from_companies_house?
    !company_number.nil?
  end

  def primary_address
    addresses.first
  end
end

Business.import force: true # for auto sync model with elastic search
