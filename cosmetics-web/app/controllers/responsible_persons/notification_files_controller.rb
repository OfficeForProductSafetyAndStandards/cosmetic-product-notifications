class ResponsiblePersons::NotificationFilesController < SubmitApplicationController
  before_action :set_responsible_person

  def new; end

  def show
    redirect_to new_responsible_person_notification_file_path(@responsible_person)
  end

  def create
    @errors = []
    if uploaded_files_params.nil?
      @errors << { text: "Select an EU notification file", href: "#uploaded_files" }
      return render :new
    end

    if direct_upload?
      DirectUploadHandlerJob.perform_later(uploaded_files_params, uploaded_files_names_params, @responsible_person.id, current_user.id)
    else
      handle_non_js_upload
    end

    redirect_to responsible_person_notifications_path(@responsible_person)
  end

  def destroy
    NotificationFile.destroy(params[:id])
    redirect_to responsible_person_notifications_path(@responsible_person)
  end

  def destroy_all
    @responsible_person.notification_files.where(user_id: current_user.id).where.not(upload_error: nil).destroy_all
    redirect_to responsible_person_notifications_path(@responsible_person)
  end

private

  def handle_non_js_upload
    if uploaded_files_params.length > NotificationFile::MAX_NUMBER_OF_FILES
      @errors << {
        text: "You can only select up to #{NotificationFile::MAX_NUMBER_OF_FILES} files at the same time",
        href: "#uploaded_files",
      }
      return render :new
    end

    uploaded_files_params.each do |uploaded_file|
      notification_file = NotificationFile.new(
        name: uploaded_file.original_filename,
        responsible_person: @responsible_person,
        user: current_user,
      )
      notification_file.uploaded_file.attach(uploaded_file)

      unless notification_file.save
        @errors.concat(notification_file.errors.full_messages.map do |message|
          { text: message, href: "#file-upload-form-group" }
        end)
        return render :new
      end

      NotificationFileProcessorJob.perform_later(notification_file.id)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def uploaded_files_params
    if params.key?(:uploaded_files)
      params.require(:uploaded_files)
    end
  end

  def uploaded_files_names_params
    if params.key?(:uploaded_files_names)
      params.require(:uploaded_files_names)
    end
  end

  def direct_upload?
    uploaded_files_params.all? { |entry| entry.is_a? String }
  end
end
