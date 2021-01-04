class ResponsiblePersons::NotificationFilesController < SubmitApplicationController
  before_action :set_responsible_person

  def new; end

  def show
    redirect_to new_responsible_person_notification_file_path(@responsible_person)
  end

  def create
    t1 = Time.zone.now.to_f
    uuid = SecureRandom.uuid
    Rails.logger.info "[#{uuid}][NotificationFileUpload] started"
    @errors = []
    if uploaded_files_params.nil?
      @errors << { text: "Select an EU notification file", href: "#uploaded_files" }
      return render :new
    end

    if uploaded_files_params.length > NotificationFile::MAX_NUMBER_OF_FILES
      @errors << {
        text: "You can only select up to #{NotificationFile::MAX_NUMBER_OF_FILES} files at the same time",
        href: "#uploaded_files",
      }
      return render :new
    end

    Rails.logger.info "[#{uuid}][NotificationFileUpload][d=#{Time.zone.now.to_f - t1}] before adding notification files"
    uploaded_files_params.each do |uploaded_file|
      notification_file = NotificationFile.new(
        name: uploaded_file.original_filename,
        responsible_person: @responsible_person,
        user: current_user,
      )
      notification_file.uploaded_file.attach(uploaded_file)
      Rails.logger.info "[#{uuid}][NotificationFileUpload][d=#{Time.zone.now.to_f - t1}] notification file attached"

      unless notification_file.save
        @errors.concat(notification_file.errors.full_messages.map do |message|
          { text: message, href: "#file-upload-form-group" }
        end)
        return render :new
      end
      Rails.logger.info "[#{uuid}][NotificationFileUpload][d=#{Time.zone.now.to_f - t1}] notification file saved"

      NotificationFileProcessorJob.perform_later(notification_file.id)
    end
    Rails.logger.info "[#{uuid}][NotificationFileUpload][d=#{Time.zone.now.to_f - t1}] after adding notification files"

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
end
