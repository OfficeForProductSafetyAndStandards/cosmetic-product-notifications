require "elasticsearch/model"

class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  default_scope { order(created_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products
end

Product.import force: true # for auto sync model with elastic search
