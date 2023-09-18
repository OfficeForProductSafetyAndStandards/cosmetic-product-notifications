class PoisonCentres::NotificationsController < SearchApplicationController
  PER_PAGE = 20

  before_action :load_notification

  def show
    @responsible_person = @notification.responsible_person
    if current_user&.poison_centre_user? || current_user&.opss_science_user?
      render "show_poison_centre"
    else
      @history = @notification.versions_with_name
      render "show_msa"
    end
  end

private

  def load_notification
    notification = Notification.find_by!(reference_number: params[:reference_number])
    authorize notification, policy_class: PoisonCentreNotificationPolicy
    @notification = NotificationSearchResultDecorator.new(notification)
  end

  def search_params
    if params[:notification_search_form]
      params.fetch(:notification_search_form, {}).permit(:q,
                                                         :category,
                                                         { date_from: %i[day month year] },
                                                         { date_to: %i[day month year] },
                                                         { date_exact: %i[day month year] },
                                                         :date_filter,
                                                         :search_fields,
                                                         :match_similar,
                                                         :sort_by)
    elsif params[:ingredient_search_form]
      params.fetch(:ingredient_search_form, {}).permit(:q,
                                                       { date_from: %i[day month year] },
                                                       { date_to: %i[day month year] },
                                                       :group_by,
                                                       :sort_by,
                                                       :exact_or_any_match)
    end
  end
  helper_method :search_params
end
