module OpenSearchQuery
  class Ingredient
    EXACT_MATCH = "exact_match".freeze
    ANY_MATCH   = "any_match".freeze

    GROUP_BY_NONE                   = "none".freeze
    GROUP_BY_RESPONSIBLE_PERSON_ASC = "responsible_person_asc".freeze

    SCORE_SORTING = "score".freeze
    DATE_ASCENDING_SORTING  = "date_ascending".freeze
    DATE_DESCENDING_SORTING = "date_descending".freeze

    FIELDS = %w[searchable_ingredients].freeze

    # Date when manual ingredients introduction for notifications was released to the service.
    # When searching for ingredients, we want to exclude notifications created before this date that may contain imported
    # ingredients from CPNP.
    INGREDIENTS_RELEASE_DATE = "2022-10-03".freeze

    def initialize(keyword:, match_type:, from_date:, to_date:, group_by: nil, sort_by: nil, responsible_person_id: nil)
      @keyword    = keyword
      @match_type = match_type
      @from_date  = start_date(from_date)
      @to_date    = to_date
      @group_by   = group_by
      @sort_by    = sort_by.presence || default_sorting
      @responsible_person_id = responsible_person_id
    end

    def build_query
      {
        query: {
          bool: {
            must: select_query,
            filter: filter_query,
          },
        },
        sort: [group_query, sort_query].compact, # "group by" is used as "order first by"
      }
    end

  private

    def select_query
      {
        ANY_MATCH => any_match_query,
        EXACT_MATCH => exact_match_query,
      }[@match_type]
    end

    def any_match_query
      {
        multi_match: {
          query: (@keyword || ""),
          fuzziness: 1,
          operator: "AND",
          fields: FIELDS,
        },
      }
    end

    def exact_match_query
      {
        match_phrase: {
          searchable_ingredients: {
            query: (@keyword || ""),
          },
        },
      }
    end

    def filter_query
      [
        filter_dates_query,
        filter_rp,
      ].compact
    end

    def filter_dates_query
      return if @from_date.blank?

      {
        range: {
          notification_complete_at: {
            gte: @from_date&.to_s,
            lte: @to_date&.to_s,
          },
        },
      }
    end

    def group_query
      { "responsible_person.id" => { order: "asc" } } if @group_by == GROUP_BY_RESPONSIBLE_PERSON_ASC
    end

    def sort_query
      {
        SCORE_SORTING => "_score",
        DATE_ASCENDING_SORTING => { notification_complete_at: { order: :asc } },
        DATE_DESCENDING_SORTING => { notification_complete_at: { order: :desc } },
      }[@sort_by]
    end

    def filter_rp
      return if @responsible_person_id.nil?

      {
        bool: {
          filter: [
            { term: { "responsible_person.id": @responsible_person_id } },
          ],
        },
      }
    end

    def default_sorting
      @keyword.present? ? SCORE_SORTING : DATE_DESCENDING_SORTING
    end

    def start_date(date)
      #  Ensures we will search, at least, from the date when manual ingredients introduction was released.
      ingredients_release_date = Date.parse(INGREDIENTS_RELEASE_DATE)
      if date && (date > ingredients_release_date)
        date
      else
        ingredients_release_date
      end
    end
  end
end
