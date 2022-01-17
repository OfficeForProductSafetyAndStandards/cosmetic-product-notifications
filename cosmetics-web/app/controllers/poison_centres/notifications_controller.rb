class PoisonCentres::NotificationsController < SearchApplicationController
  PER_PAGE = 20

  def index
    @search_form = NotificationSearchForm.new(search_params)
    @search_form.validate

    @result = search_notifications
    # Notifications are only listed in ElasticSearch index when completed, but if an indexed notification gets deleted,
    # it won't be removed from the index until the next reindex is run (once per day).
    # During that period, the result record will be a deleted notification with empty values. We don't want to show those.
    @notifications = @result.records.completed.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @notification = Notification.find_by! reference_number: params[:reference_number]
    authorize @notification, policy_class: PoisonCentreNotificationPolicy
    if current_user&.poison_centre_user?
      render "show_poison_centre"
    else
      @contact_person = @notification.responsible_person.contact_persons.first
      render "show_msa"
    end
  end

private

  def search_notifications
    query = ElasticsearchQuery.new(keyword: @search_form.q, category: @search_form.category, from_date: @search_form.date_from_for_search, to_date: @search_form.date_to_for_search, sort_by: @search_form.sort_by)
    Notification.full_search(query)
  end

  def search_params
    params.fetch(:notification_search_form, {}).permit(:q,
                                                       :category,
                                                       { date_from: %i[day month year] },
                                                       { date_to: %i[day month year] },
                                                       { date_exact: %i[day month year] },
                                                       :date_filter,
                                                       :sort_by)
  end
  helper_method :search_params
end
