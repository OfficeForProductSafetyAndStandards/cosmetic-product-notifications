class PoisonCentres::IngredientsSearchController < SearchApplicationController
  PER_PAGE = 20

  def show
    @search_form = IngredientSearchForm.new(search_params)
    @search_params = search_params

    if search_params.present? && params["edit"].nil?
      apply_date_filter
      if @search_form.valid?
        @search_response = search_notifications
        @notifications = @search_response.records
      end
    end
  end

private

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

  def search_notifications
    query = OpenSearchQuery::Ingredient.new(keyword: @search_form.q,
                                            match_type: @search_form.exact_or_any_match,
                                            from_date: @search_form.date_from_for_search,
                                            to_date: @search_form.date_to_for_search,
                                            group_by: @search_form.group_by,
                                            sort_by: @search_form.sort_by)
    # Pagination needs to be kept together with the full search query to automatically paginate the query with Kaminari values
    # instead of defaulting to OpenSearch returning the first 10 hits.
    search_result = Notification.full_search(query).page(params[:page]).per(PER_PAGE)

    SearchHistory.create(query: @search_form.q, sort_by: @search_form.sort_by, results: search_result.results.total)

    search_result
  end
end
