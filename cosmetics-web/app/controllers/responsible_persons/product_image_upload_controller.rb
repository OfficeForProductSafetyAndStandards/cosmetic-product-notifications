class ResponsiblePersons::ProductImageUploadController < SubmitApplicationController
  before_action :set_models

  def new; end

  def create
    return render_missing_file_error if params[:image_upload].blank?

    params[:image_upload].each { |img| add_image_to_notification(img) }
    if @notification.save
      redirect_to responsible_person_notification_additional_information_index_path(
        @notification.responsible_person,
        @notification,
      )
    else
      render_image_upload_errors
    end
  end

private

  def render_missing_file_error
    add_error "No file selected"
    render :new
  end

  def add_image_to_notification(image)
    image_upload = @notification.image_uploads.build
    image_upload.file.attach(image)
    image_upload.filename = image.original_filename
  end

  def render_image_upload_errors
    @notification.image_uploads.each do |image_upload|
      image_upload.errors.messages[:file].map(&method(:add_error))
    end
    render :new
  end

  def add_error(error_message)
    @error_list.push(text: error_message, href: "#image_upload")
  end

  def set_models
    @error_list = []
    @notification = Notification.find_by reference_number: params[:notification_reference_number]
    @responsible_person = @notification.responsible_person
    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
