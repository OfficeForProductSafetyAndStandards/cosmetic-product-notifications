class PoisonCentres::NotificationsController < SearchApplicationController
  PER_PAGE = 20

  before_action :load_notification
  before_action :load_addresses, only: [:full_address_history]

  def show
    @responsible_person = @notification.responsible_person
    @history = @notification.versions_with_name

    if current_user.can_view_product_ingredients_with_percentages?
      @show_ingredient_percentages = true
      render "show_detail"
    elsif current_user.can_view_product_ingredients_without_percentages?
      @show_ingredient_percentages = false
      render "show_detail"
    else
      # OPSS general users do not have access to any ingredient details
      render "show"
    end
  end

  def full_address_history
    @responsible_person = @notification.responsible_person
  end

private

  def load_addresses
    authorize @notification, :full_address_history?, policy_class: PoisonCentreNotificationPolicy
    @addresses = @notification.responsible_person.address_logs.newest_first
  end

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
