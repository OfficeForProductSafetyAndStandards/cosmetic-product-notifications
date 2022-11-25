class PoisonCentres::IngredientsSearchController < SearchApplicationController
  PER_PAGE = 20

  def show
    @search_form = IngredientSearchForm.new(search_params)
    @search_form.validate

    if search_params.present?
      apply_date_filter
    end

    @search_response = search_notifications
    # Notifications are only listed in ElasticSearch index when completed, but if an indexed notification gets deleted,
    # it won't be removed from the index until the next reindex is run (once per day).
    # During that period, the result record will be a deleted notification with empty values. We don't want to show those.
    @notifications = @search_response.records.includes(:responsible_person).completed
  end

private

  def search_notifications
    query = OpenSearchQuery::Ingredient.new(keyword: @search_form.q,
                                            match_type: @search_form.exact_or_any_match,
                                            from_date: @search_form.date_from_for_search,
                                            to_date: @search_form.date_to_for_search,
                                            group_by: @search_form.group_by,
                                            sort_by: @search_form.sort_by)
    Rails.logger.debug query.build_query.to_json
    # Pagination needs t  o be kept together with the full search query to automatically paginate the query with Kaminari values
    # instead of defaulting to OpenSearch returning the first 10 hits.
    search_result = Notification.full_search(query).page(params[:page]).per(PER_PAGE)

    SearchHistory.create(query: @search_form.q, results: search_result.results.total)

    search_result
  end

  # Any changes in these search params need to be also applied to PoisonCentres::NotificationsController#search_params
  def search_params
    params.fetch(:ingredient_search_form, {}).permit(:q,
                                                     { date_from: %i[day month year] },
                                                     { date_to: %i[day month year] },
                                                     :group_by,
                                                     :sort_by,
                                                     :exact_or_any_match)
  end

  def apply_date_filter
    if @search_form.date_from.present? || @search_form.date_to.present?
      @search_form.date_filter = IngredientSearchForm::FILTER_BY_DATE_RANGE
    end
  end

  helper_method :search_params
end
