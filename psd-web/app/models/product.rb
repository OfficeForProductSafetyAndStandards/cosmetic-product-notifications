class Product < ApplicationRecord
  include Shared::Web::CountriesHelper
  include Documentable
  include Searchable
  include AttachmentConcern
  include SanitizationHelper

  index_name [Rails.env, "products"].join("_")

  before_validation { trim_line_endings(:description) }
  validates :name, presence: true
  validates :product_type, presence: true
  validates :category, presence: { message: "Select a valid product category" }
  validates_length_of :description, maximum: 10000

  has_many_attached :documents

  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products

  has_many :corrective_actions, dependent: :destroy
  has_many :tests, dependent: :destroy

  has_one :source, as: :sourceable, dependent: :destroy

  def country_of_origin_for_display
    country_from_code(country_of_origin) || country_of_origin
  end

  def pretty_description
    "Product: #{name}"
  end
end

Product.import force: true if Rails.env.development? # for auto sync model with elastic search
