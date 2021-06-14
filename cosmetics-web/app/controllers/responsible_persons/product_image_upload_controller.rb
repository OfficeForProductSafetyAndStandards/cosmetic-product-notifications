class ResponsiblePersons::ProductImageUploadController < SubmitApplicationController
  before_action :set_models

  def new; end

  def edit; end

  def create
    return render_missing_file_error if params[:image_upload].blank?

    params[:image_upload].each { |img| @notification.add_image(img) }
    if @notification.save
      redirect_to responsible_person_notification_additional_information_index_path(
        @responsible_person,
        @notification,
      )
    else
      render_image_upload_errors
    end
  end

  def update
    return render_missing_file_error if @notification.image_uploads.none? && params[:image_upload].blank?

    params[:image_upload].each { |img| @notification.add_image(img) }
    if @notification.save
      redirect_to edit_responsible_person_notification_path(@responsible_person, @notification)
    else
      render_image_upload_errors
    end
  end

  # It is restricted to the user? (need to check if needs Pundit rule) --> Request spec
  # Probably set models authorisation is enough
  def destroy
    ImageUpload.find(params[:id]).destroy
    redirect_to action: :edit, host: ENV["SUBMIT_HOST"]
  end

private

  def render_missing_file_error
    add_error "No file selected"
    render :new
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

    return redirect_to responsible_person_notification_path(@responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
