module Searchable
  extend ActiveSupport::Concern
  included do
    include Shared::Web::Concerns::Searchable

    def self.full_search(query)
      # This line makes sure elasticsearch index is recreated before we search
      # It fixes the issue of getting no results the first time product list page is loaded
      # It's only used in dev because it lowers performance and the issue it fixes should be an edge case in production
      __elasticsearch__.refresh_index! if Rails.env.development? || Rails.env.test?
      __elasticsearch__.search(query.build_query)
    end
  end
end
