class Address < ApplicationRecord
  validates :address_type, presence: true
  default_scope { order(created_at: :asc) }
  belongs_to :business
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail

  def summary
    [
      line_1,
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
    self.address_type = "Registered office address"
    self.line_1 = registered_office["address_line_1"]
    self.line_2 = registered_office["address_line_2"]
    self.locality = registered_office["locality"]
    self.country = registered_office["country"]
    self.postal_code = registered_office["postal_code"]
    self.source ||= ReportSource.new(name: "Companies House")
    save
    self
  end
end
