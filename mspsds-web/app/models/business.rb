class Business < ApplicationRecord
  include BusinessesHelper
  include Searchable
  include Documentable
  include AttachmentConcern

  index_name [Rails.env, "businesses"].join("_")

  settings do
    mappings do
      indexes :company_number, type: :keyword
      indexes :company_type_code, type: :keyword, fields: { sort: { type: "keyword" } }
      indexes :company_status_code, type: :keyword, fields: { sort: { type: "keyword" } }
    end
  end

  validates :legal_name, presence: true

  has_many_attached :documents

  has_many :investigation_businesses, dependent: :destroy
  has_many :investigations, through: :investigation_businesses
  has_one :contact, dependent: :destroy

  has_many :locations, dependent: :destroy
  has_many :corrective_actions, dependent: :destroy

  accepts_nested_attributes_for :locations, reject_if: :all_blank
  accepts_nested_attributes_for :contact, reject_if: :all_blank

  has_one :source, as: :sourceable, dependent: :destroy

  def primary_location
    locations.first
  end

  def primary_contact
    contact
  end

  def name
     trading_name || legal_name
  end

  def pretty_description
    "Business #{id}"
  end

private

  def add_sic_code(c_h_info)
    self.nature_of_business_id = c_h_info["sic_codes"][0] if c_h_info["sic_codes"].present?
  end

  def add_registered_location(registered_office)
    registered_office_location = primary_location || locations.build
    registered_office_location.with_registered_office_info(registered_office)
  end
end

Business.import force: true if Rails.env.development? # for auto sync model with elastic search
