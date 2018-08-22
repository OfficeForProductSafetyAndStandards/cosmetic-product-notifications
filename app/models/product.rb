require "elasticsearch/model"

class Product < ApplicationRecord
  include CountriesHelper
  include Searchable

  index_name [Rails.env, "products"].join("_")

  settings index: { number_of_shards: 1 } do
    mappings do
      indexes :name, type: :keyword
      indexes :brand, type: :keyword
      indexes :category, type: :keyword
      indexes :country_of_origin, type: :keyword
    end
  end

  default_scope { order(created_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products
  has_many :images, dependent: :destroy, inverse_of: :product
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :images, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :source

  has_paper_trail

  def country_of_origin_for_display
    country_from_code country_of_origin
  end
end

Product.import force: true # for auto sync model with elastic search
