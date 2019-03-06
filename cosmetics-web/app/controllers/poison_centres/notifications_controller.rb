class PoisonCentres::NotificationsController < ApplicationController
  def index
    @notifications = get_registered_notifications(10)
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
end
