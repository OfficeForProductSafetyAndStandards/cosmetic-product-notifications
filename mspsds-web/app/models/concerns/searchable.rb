module Searchable
  extend ActiveSupport::Concern

  included do
    include Shared::Web::Concerns::Searchable

    def self.full_search(query)
      # This line makes sure elasticsearch index is recreated before we search
      # It fixes the issue of getting no results the first time case list page is loaded
      # It's only used in dev because it lowers performance and the issue it fixes should be an edge case in production
      __elasticsearch__.refresh_index! if Rails.env.development? || Rails.env.test?
      __elasticsearch__.search(query.build_query(highlighted_fields, fuzzy_fields, exact_fields))
    end

    # "prefix" may be changed to a more appropriate query. For alternatives see:
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/term-level-queries.html
    def self.prefix_search(params, field)
      query = {}
      if params[:query].present?
        query[:query] = {
          prefix: {
            "#{field}": params[:query]
          }
        }
      end
      query[:sort] = sort_params(params) if params[:sort].present?

      __elasticsearch__.search(query)
    end

    def self.sort_params(params)
      sort_field = params[:sort] + ".sort"
      [{ "#{sort_field}": { order: params[:direction] } }]
    end

    def self.highlighted_fields
      # To be overwritten by the model using it, defaults to all sent fields
      %w[*]
    end

    def self.fuzzy_fields
      # To be overwritten by the model using it, defaults to all fields
      []
    end

    def self.exact_fields
      # To be overwritten by the model using it, defaults to all fields
      # Bear in mind that if you have a field both here and in fuzzy_fields, your result will just be fuzzy
      []
    end
  end
end
