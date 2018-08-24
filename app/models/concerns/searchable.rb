module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # "prefix" may be changed to a more appropriate query. For alternatives see:
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/term-level-queries.html
    def self.prefix_search(query)
      __elasticsearch__.search(
        # TODO-MSPSDS-298 Re-enable prefix search
        # query: {
        #   prefix: {
        #     _all: {
        #       value: query.downcase # analyzer indexes records in lowercase
        #     }
        #   }
        # }
        query
      )
    end
  end
end
