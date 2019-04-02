class ProductImageUploadController < ApplicationController
  before_action :set_models

  def new; end

  def create
    if params[:image_upload].present?
      params[:image_upload].each do |image|
        image_upload = @notification.image_uploads.build
        image_upload.file.attach(image)
        image_upload.filename = image.original_filename
      end

      if @notification.save
        redirect_to responsible_person_notification_additional_information_index_path(@notification.responsible_person, @notification)
      else
        @notification.errors.messages[:image_upload].map(&method(:add_error))
        render :new
      end
    else
      add_error "No file selected"
      render :new
    end
  end

private

  def add_error error_message
    @error_list.push(text: error_message, href: "#image_upload")
  end

  def set_models
    @error_list = []
    @notification = Notification.find_by reference_number: params[:notification_reference_number]
    @responsible_person = @notification.responsible_person
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
  end
end
