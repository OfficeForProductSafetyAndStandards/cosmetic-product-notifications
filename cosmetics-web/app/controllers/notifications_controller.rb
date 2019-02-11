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
      add_image_upload_errors
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
    @notification = Notification.where(reference_number: params[:id]).first
  end

  def add_image_upload_errors
    if @notification.images_failed_anti_virus_check?
      @notification.errors.add :image_uploads, "failed anti virus check"
    end

    if @notification.images_pending_anti_virus_check?
      @notification.errors.add :image_uploads, "waiting for files to pass anti virus check. Refresh to update"
    end
  end
end
