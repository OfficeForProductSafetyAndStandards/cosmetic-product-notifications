class Location < ApplicationRecord
  default_scope { order(created_at: :asc) }

  belongs_to :business

  has_one :source, as: :sourceable, dependent: :destroy

  def summary
    [
      address_line_1,
      address_line_2,
      postal_code,
      country
    ].reject(&:blank?).join(", ")
  end

  def short
    [
      locality,
      country
    ].reject(&:blank?).join(", ")
  end

  def from_companies_house?
    source.show == "Companies House"
  end

  def with_registered_office_info(registered_office)
    self.name = "Registered office address"
    self.address = "#{registered_office['address_line_1']}, #{registered_office['address_line_2']}"
    self.phone_number = registered_office["phone_number"]
    self.locality = registered_office["locality"]
    self.country = registered_office["country"]
    self.postal_code = registered_office["postal_code"]
    self.source ||= ReportSource.new(name: "Companies House")
    save
    self
  end
end
