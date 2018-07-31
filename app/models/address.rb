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
    ].reject(&:empty?).join(", ")
  end
end
