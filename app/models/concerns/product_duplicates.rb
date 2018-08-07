require "active_support/concern"

module ProductDuplicates
  extend ActiveSupport::Concern

  included do
    after_create :search_for_duplicates

    has_many :potential_product_duplicates, dependent: :destroy
    has_many :duplicate_products, through: :potential_product_duplicates
  end

  private

  SEARCH_PROPERTIES = [
    { key: :name, weighting: 3 },
    { key: :gtin, weighting: 6 },
    { key: :model, weighting: 1 },
    { key: :brand, weighting: 1 },
    { key: :mpn, weighting: 4 },
    { key: :batch_number, weighting: 2 },
    { key: :description, weighting: 0.2 }
  ].freeze

  ELASTICSEARCH_THRESHOLD = 90

  def search_for_duplicates
    duplicates = Product.search(construct_search_query)
    duplicates.each do |result|
      if result._score > ELASTICSEARCH_THRESHOLD
        potential_product_duplicates.create(duplicate_product_id: result.id, score: result._score)
      end
    end
  end

  def construct_search_query
    {
      query: {
        bool: {
          should: construct_query_from_properties
        }
      }
    }
  end

  def construct_query_from_properties
    SEARCH_PROPERTIES
      .reject { |property| self[property[:key]].blank? }
      .collect do |property|
        query = {
          match: {}
        }
        query[:match][property[:key]] = {
          "query": self[property[:key]],
          "boost": property[:weighting]
        }
        query
      end
  end
end
