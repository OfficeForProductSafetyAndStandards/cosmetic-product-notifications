class ResponsiblePersons::NotificationFilesController < ApplicationController
  before_action :set_responsible_person

  def new; end

  def show
    redirect_to new_responsible_person_notification_file_path(@responsible_person)
  end

  def create
    @errors = []
    if uploaded_files_params.nil?
      @errors << { text: "No files selected", href: "#uploaded_files" }
      return render :new
    end

    if uploaded_files_params.length > NotificationFile.get_max_number_of_files
      @errors << {
          text: "Too many files selected. Please select no more than #{NotificationFile.get_max_number_of_files} files",
          href: "#uploaded_files"
      }
      return render :new
    end

    uploaded_files_params.each do |uploaded_file|
      notification_file = NotificationFile.new(
        name: uploaded_file.original_filename,
        responsible_person: @responsible_person,
        user: User.current
      )
      notification_file.uploaded_file.attach(uploaded_file)

      unless notification_file.save
        @errors.concat(notification_file.errors.full_messages.map { |message|
          { text: message, href: "#file-upload-form-group" }
        })
        return render :new
      end
    end
    redirect_to responsible_person_notifications_path(@responsible_person)
  end

  def destroy
    NotificationFile.delete(params[:id])
    redirect_to responsible_person_notifications_path(@responsible_person)
  end

  def destroy_all
    @responsible_person.notification_files.where(user_id: User.current.id).where.not(upload_error: nil).delete_all
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
    if params.has_key?(:uploaded_files)
      params.require(:uploaded_files)
    end
  end
end
