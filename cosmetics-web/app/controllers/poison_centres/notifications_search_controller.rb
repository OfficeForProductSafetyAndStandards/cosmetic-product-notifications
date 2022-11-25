class PoisonCentres::NotificationsSearchController < SearchApplicationController
  PER_PAGE = 20

  def show
    @search_form = NotificationSearchForm.new(search_params)
    @search_form.validate

    @search_response = search_notifications
    @notifications = @search_response.records
  end

private

  def search_notifications
    query = OpenSearchQuery::Notification.new(
      keyword: @search_form.q,
      category: @search_form.category,
      from_date: @search_form.date_from_for_search,
      to_date: @search_form.date_to_for_search,
      sort_by: @search_form.sort_by,
      match_similar: @search_form.match_similar,
      search_fields: @search_form.search_fields,
      responsible_person_id: nil,
    )
    Rails.logger.debug query.build_query.to_json
    # Pagination needs to be kept together with the full search query to automatically paginate the query with Kaminari values
    # instead of defaulting to OpenSearch returning the first 10 hits.
    search_result = Notification.full_search(query).page(params[:page]).per(PER_PAGE)

    SearchHistory.create(query: @search_form.q, results: search_result.results.total)

    search_result
  end

  # Any changes in these search params need to be also applied to PoisonCentres::NotificationsController#search_params
  def search_params
    params.fetch(:notification_search_form, {}).permit(:q,
                                                       :category,
                                                       { date_from: %i[day month year] },
                                                       { date_to: %i[day month year] },
                                                       { date_exact: %i[day month year] },
                                                       :date_filter,
                                                       :sort_by,
                                                       :search_fields,
                                                       :match_similar)
  end
  helper_method :search_params
end
