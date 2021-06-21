class PoisonCentres::NotificationsController < SearchApplicationController
  def index
    @search_form = NotificationSearchForm.new(search_params)
    @search_form.valid?

    @result = search_notifications(10)
    @notifications = @result.records
  end

  def show
    @notification = Notification.find_by reference_number: params[:reference_number]
    authorize @notification, policy_class: PoisonCentreNotificationPolicy
    if current_user&.poison_centre_user?
      render "show_poison_centre"
    else
      @contact_person = @notification.responsible_person.contact_persons.first
      render "show_msa"
    end
  end

private

  def search_notifications(page_size)
    query = ElasticsearchQuery.new(keyword: @search_form.q, category: @search_form.category, from_date: @search_form.date_from_for_search, to_date: @search_form.date_to_for_search)
    Notification.full_search(query).paginate(page: params[:page], per_page: page_size)
  end

  def search_params
    params.fetch(:notification_search_form, {}).permit(:q,
                                                       :category,
                                                       { date_from: %i[day month year] },
                                                       { date_to: %i[day month year] },
                                                       { date_exact: %i[day month year] },
                                                       :date_filter)
  end
  helper_method :search_params
end
