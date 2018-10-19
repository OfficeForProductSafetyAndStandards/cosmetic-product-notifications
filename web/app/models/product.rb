class Product < ApplicationRecord
  include CountriesHelper
  include Documentable
  include Searchable

  index_name [Rails.env, "products"].join("_")

  default_scope { order(created_at: :desc) }

  validates :name, presence: true
  has_many_attached :documents
  has_many_attached :images

  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products

  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail

  def country_of_origin_for_display
    country_from_code(country_of_origin) || country_of_origin
  end

  def get_first_image
    images.attachments.first
  end
end

Product.import force: true # for auto sync model with elastic search
