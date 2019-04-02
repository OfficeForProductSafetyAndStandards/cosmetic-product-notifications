require 'will_paginate/array'

class ResponsiblePersons::NotificationsController < ApplicationController
  before_action :set_responsible_person
  before_action :set_notification, only: %i[show edit confirm]

  def index
    @pending_notification_files_count = 0
    @erroneous_notification_files = []

    @responsible_person.notification_files.where(user_id: User.current.id).each do |notification_file|
      if notification_file.upload_error
        @erroneous_notification_files << notification_file
      else
        @pending_notification_files_count += 1
      end
    end

    @erroneous_notification_files = @erroneous_notification_files.paginate(page: params[:errors], per_page: 10)

    @unfinished_notifications = get_unfinished_notifications(10)

    @registered_notifications = get_registered_notifications(10)
  end

  def show; end

  def new
    was_notified_before_eu_exit = params["notified_before_eu_exit"] == "true"

    @notification = Notification.create(
      responsible_person: @responsible_person,
      was_notified_before_eu_exit: was_notified_before_eu_exit
    )

    redirect_to new_responsible_person_notification_build_path(@responsible_person, @notification)
  end

  # Check your answers page
  def edit
    if params[:submit_failed]
      add_image_upload_errors
    end
  end

  def confirm
    if @notification.submit_notification!
      redirect_to responsible_person_notifications_path(@responsible_person), confirmation: "#{@notification.product_name} registered"
    else
      redirect_to edit_responsible_person_notification_path(@responsible_person, @notification, submit_failed: true)
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:reference_number]
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def get_unfinished_notifications(page_size)
    @responsible_person.notifications
      .where(state: %i[notification_file_imported draft_complete])
      .paginate(page: params[:unfinished], per_page: page_size)
  end

  def get_registered_notifications(page_size)
    @responsible_person.notifications
      .where(state: :notification_complete)
      .paginate(page: params[:registered], per_page: page_size)
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
