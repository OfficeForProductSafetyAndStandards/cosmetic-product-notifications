class ResponsiblePersons::SearchIngredientsController < SubmitApplicationController
  PER_PAGE = 20

  before_action :set_responsible_person

  def show
    @search_form = IngredientSearchForm.new(search_params)

    #@search_form.sort_by = OpenSearchQuery::Notification::SCORE_SORTING
    @search_params = search_params

    if search_params.present? && params["edit"].nil?
      apply_date_filter
      if @search_form.valid?
        @search_response = search_notifications

        # Notifications are only listed in ElasticSearch index when completed, but if an indexed notification gets deleted,
        # it won't be removed from the index until the next reindex is run (once per day).
        # During that period, the result record will be a deleted notification with empty values. We don't want to show those.
        @notifications = @search_response.records.completed
      end
    end
  end

  private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def search_params
    params.fetch(:ingredient_search_form, {}).permit(:q,
                                                     { date_from: %i[day month year] },
                                                     { date_to: %i[day month year] },
                                                     :sort_by,
                                                     :exact_or_any_match)
  end

  def apply_date_filter
    if @search_form.date_from.present? || @search_form.date_to.present?
      @search_form.date_filter = NotificationSearchForm::FILTER_BY_DATE_RANGE
    end
  end

  def search_notifications
    query = OpenSearchQuery::Ingredient.new(keyword: @search_form.q, match_type: @search_form.exact_or_any_match, from_date: @search_form.date_from_for_search, to_date: @search_form.date_to_for_search, sort_by: @search_form.sort_by)
    Rails.logger.debug query.build_query.to_json
    # Pagination needs t  o be kept together with the full search query to automatically paginate the query with Kaminari values
    # instead of defaulting to OpenSearch returning the first 10 hits.
    search_result = Notification.full_search(query).page(params[:page]).per(PER_PAGE)

    SearchHistory.create(query: @search_form.q, results: search_result.results.total)

    search_result
  end
end
