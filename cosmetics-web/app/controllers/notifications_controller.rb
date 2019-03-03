class NotificationsController < ApplicationController
  skip_before_action :redirect_poison_centre_user

  def index
    @notifications = get_registered_notifications(10)
  end

  def show
    @notification = Notification.find_by reference_number: params[:reference_number]
  end

private

  def get_registered_notifications(page_size)
    Notification.where(state: :notification_complete)
      .paginate(page: params[:page], per_page: page_size)
  end
end
