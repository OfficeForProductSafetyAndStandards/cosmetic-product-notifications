class PoisonCentres::NotificationsController < ApplicationController
  def index
    @notifications = get_registered_notifications(10)
    query = query_params[:q] || ""
    @result = Notification.full_search({
                                         query: {
                                          multi_match: {
                                            query: query,
                                            fuzziness: "AUTO"
                                          }
                                         }
                                       })
    @result = @result.paginate(page: 1, per_page: 10)
  end

  def show
    @notification = Notification.find_by reference_number: params[:reference_number]
    authorize @notification, policy_class: PoisonCentreNotificationPolicy
  end

private

  def authorize_user!
    raise Pundit::NotAuthorizedError unless poison_centre_user?
  end

  def get_registered_notifications(page_size)
    Notification.where(state: :notification_complete)
      .paginate(page: params[:page], per_page: page_size)
  end

  def query_params
    params.permit(:q)
  end
end
