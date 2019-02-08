class NotificationsController < ApplicationController
  before_action :set_notification
  skip_before_action :set_notification, only: [:new]

  def new
    @notification = Notification.create
    redirect_to new_notification_build_path(@notification)
  end

    # Check your answers page
  def edit
    if params[:submit_failed]
      if @notification.image_uploads.all?(&:file_exists?)
        unless @notification.image_uploads.all?(&:marked_as_safe?)
          @notification.errors.add :image_uploads, "waiting for files to pass anti virus check..."
        end
      else
        @notification.errors.add :image_uploads, "failed anti virus check"
      end
    end
  end

    # Confirmation page
  def confirmation
    if @notification.may_submit_notification?
      @notification.submit_notification!
    elsif @notification.state != "notification_complete"
      redirect_to edit_notification_path(@notification, submit_failed: true)
    end
  end

private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end
