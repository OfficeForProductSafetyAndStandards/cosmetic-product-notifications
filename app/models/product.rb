require "elasticsearch/model"

class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.env, "products"].join("_")

  default_scope { order(created_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products
  has_many :images, dependent: :destroy, inverse_of: :product

  accepts_nested_attributes_for :images, reject_if: :all_blank, allow_destroy: true

  has_paper_trail
end

Product.import force: true # for auto sync model with elastic search
