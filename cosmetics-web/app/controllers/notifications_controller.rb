class NotificationsController < ApplicationController
  before_action :set_notification
  skip_before_action :set_notification, only: [:new]

  def new
    @notification = Notification.create
    redirect_to new_notification_build_path(@notification)
  end

    # Check your answers page
  def edit; end

    # Confirmation page
  def confirmation
    if @notification.may_submit_notification?
      @notification.submit_notification!
    elsif @notification.state != "notification_complete"
      redirect_to edit_notification_path(@notification)
    end
  end

private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end
