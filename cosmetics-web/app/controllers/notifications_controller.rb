class NotificationsController < ApplicationController
  before_action :set_notification

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
