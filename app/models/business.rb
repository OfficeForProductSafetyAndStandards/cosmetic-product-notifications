class Business < ApplicationRecord
  validates :company_name, presence: true
  default_scope { order(created_at: :desc) }
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail

  def nature_of_business
    Rails.application.config.companies_house_constants["sic_descriptions"][nature_of_business_id]
  end

  def company_type
    Rails.application.config.companies_house_constants["company_type"][company_type_code]
  end
end
