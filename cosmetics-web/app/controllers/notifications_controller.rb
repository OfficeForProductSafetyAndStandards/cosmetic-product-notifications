class NotificationsController < ApplicationController
    # Check your answers page
  def edit
    @notification = Notification.find(params[:id])
  end

    # Confirmation page
  def confirmation
    @notification = Notification.find(params[:id])
    if !@notification.may_submit_notification?
      redirect_to edit_notification_path(@notification)
    else
      @notification.submit_notification!
    end
  end
end
