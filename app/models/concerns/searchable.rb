module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # "prefix" may be changed to a more appropriate query. For alternatives see:
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/term-level-queries.html
    def self.prefix_search(params)
      __elasticsearch__.search({
        query: {
          prefix: {
            _all: {
              value: params[:q].downcase # analyzer indexes records in lowercase
            }
          }
        },
        sort: [
          { "#{params[:sort]}": {order: params[:direction]} }
        ]
      })
    end
  end
end
