module OpenSearchQuery
  class Notification
    SCORE_SORTING = "score".freeze
    DATE_ASCENDING_SORTING  = "date_ascending".freeze
    DATE_DESCENDING_SORTING = "date_descending".freeze
    DEFAULT_SORT = SCORE_SORTING

    SEARCH_ALL_FIELDS = "all_fields".freeze
    SEARCH_RESPONSIBLE_PERSON_FIELDS = "responsible_person_fields".freeze
    SEARCH_NOTIFICATION_NAME_FIELD = "notification_name_field".freeze

    NOTIFICATION_SEARCHABLE_FIELDS = %w[product_name reference_number].freeze
    RESPONSIBLE_PERSON_SEARCHABLE_FIELDS = %w[responsible_person.name
                                              responsible_person.address_line_1
                                              responsible_person.address_line_2
                                              responsible_person.city
                                              responsible_person.county
                                              responsible_person.postal_code].freeze
    ALL_FIELDS = %w[product_name
                    reference_number
                    reference_number_for_display
                    responsible_person.name
                    responsible_person.address_line_1
                    responsible_person.address_line_2
                    responsible_person.city
                    responsible_person.county
                    responsible_person.postal_code].freeze

    MULTI_MATCH_FIELDS = { SEARCH_RESPONSIBLE_PERSON_FIELDS => RESPONSIBLE_PERSON_SEARCHABLE_FIELDS,
                           SEARCH_NOTIFICATION_NAME_FIELD => NOTIFICATION_SEARCHABLE_FIELDS,
                           SEARCH_ALL_FIELDS => ALL_FIELDS }.freeze

    def initialize(keyword:, category:, from_date:, to_date:, sort_by:, match_similar:, search_fields:)
      @keyword   = keyword
      @category  = category
      @from_date = from_date
      @to_date   = to_date
      @sort_by   = sort_by.presence || default_sorting
      @match_similar = match_similar
      @search_fields = search_fields
    end

    def build_query
      {
        query: {
          bool: {
            must: search_query,
            filter: filter_query,
          },
        },
        sort: [
          sort_query,
        ],
      }
    end

  private

    def search_query
      @keyword.blank? ? match_all_query : multi_match_query
    end

    def match_all_query
      {
        match_all: {},
      }
    end

    def multi_match_query
      {
        multi_match: {
          query: @keyword,
          fuzziness: @match_similar.present? ? "AUTO" : 0,
          operator: "AND",
          fields: MULTI_MATCH_FIELDS[@search_fields].presence || ALL_FIELDS,
        },
      }
    end

    def filter_query
      [
        filter_categories_query,
        filter_dates_query,
      ].compact
    end

    def filter_categories_query
      return if @category.blank?

      {
        nested: {
          path: "components",
          query: {
            bool: {
              should: [
                { term: { "components.display_root_category": @category } },
              ],
            },
          },
        },
      }
    end

    def filter_dates_query
      return if @from_date.nil? || @to_date.nil?

      {
        range: {
          notification_complete_at: {
            gte: @from_date,
            lte: @to_date,
          },
        },
      }
    end

    def sort_query
      {
        SCORE_SORTING => "_score",
        DATE_ASCENDING_SORTING => { notification_complete_at: { order: :asc } },
        DATE_DESCENDING_SORTING => { notification_complete_at: { order: :desc } },
      }[@sort_by]
    end

    def default_sorting
      @keyword.present? ? SCORE_SORTING : DATE_DESCENDING_SORTING
    end
  end
end
