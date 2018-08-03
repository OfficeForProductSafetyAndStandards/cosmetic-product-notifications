require "elasticsearch/model"

class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.env, "products"].join("_")

  after_create :search_for_duplicates

  default_scope { order(created_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products
  has_many :images, dependent: :destroy, inverse_of: :product
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :images, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :source

  has_paper_trail

  private

  def search_for_duplicates
    duplicates = Product.search(construct_search_query)
    puts "_______________________________________________________________________________________________________________________________________________________"
    puts duplicates.size
    puts duplicates.collect(&:_score)
  end

  def construct_search_query
    {
      query: {
        bool: {
          should: priority_fields + other_fields
        }
      }
    }
  end

  def priority_fields
    construct_query_from_keys(%i[name gtin model], 2)
  end

  def other_fields
    construct_query_from_keys(%i[brand mpn batch_number], 1)
  end

  def construct_query_from_keys(keys, boost)
    keys.reject { |key| self[key].blank? }
        .collect do |key|
          query = {
            match: {}
          }
          query[:match][key] = {
            "query": self[key],
            "boost": boost
          }
          query
        end
  end
end

Product.import force: true # for auto sync model with elastic search
