class PoisonCentres::NotificationsController < ApplicationController
  include QueryHelper
  def index
    @query = query_params[:q] || ""
    result = Notification.full_search(build_query).paginate(page: params[:page], per_page: 10)
    @notifications = result.records
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
                                                                