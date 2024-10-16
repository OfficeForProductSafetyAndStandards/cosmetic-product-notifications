class ResponsiblePersons::SearchNotificationsController < SubmitApplicationController
  PER_PAGE = 20

  before_action :set_responsible_person

  def show
    @search_form = NotificationSearchForm.new(search_params)
    @search_params = search_params

    if search_params.present? && params["edit"].nil?
      apply_date_filter
      if @search_form.valid?
        @search_response = search_notifications
        @notifications = @search_response.records
        @results_total = @search_response.results.total
      end
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  # Any changes in these search params need to be also applied to ResponsiblePersons::NotificationsController#search_params
  def search_params
    params.fetch(:notification_search_form, {}).permit(:q, :status, :sort_by,
                                                       { date_from: %i[day month year] },
                                                       { date_to: %i[day month year] })
  end
  helper_method :search_params

  def apply_date_filter
    if @search_form.date_from.present? || @search_form.date_to.present?
      @search_form.date_filter = NotificationSearchForm::FILTER_BY_DATE_RANGE
    end
  end

  def search_notifications
    query = OpenSearchQuery::Notification.new(
      keyword: @search_form.q,
      category: @search_form.category,
      from_date: @search_form.date_from_for_search,
      to_date: @search_form.date_to_for_search,
      status: @search_form.status,
      sort_by: @search_form.sort_by,
      match_similar: @search_form.match_similar,
      search_fields: @search_form.search_fields,
      responsible_person_id: @responsible_person.id,
    )
    Rails.logger.debug query.build_query.to_json
    # Pagination needs to be kept together with the full search query to automatically paginate the query with Kaminari values
    # instead of defaulting to OpenSearch returning the first 10 hits.
    search_result = Notification.full_search(query).page(params[:page]).per(PER_PAGE)

    SearchHistory.create(query: @search_form.q, sort_by: @search_form.sort_by, results: search_result.results.total)

    search_result
  end
end
