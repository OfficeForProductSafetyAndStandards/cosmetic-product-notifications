class ResponsiblePersons::NotificationFilesController < ApplicationController
  before_action :set_responsible_person
  before_action :set_notification_file

  def new; end

  def create
    @notification_file.responsible_person = @responsible_person
    @notification_file.user = current_user
    if notification_file_params && notification_file_params[:uploaded_file]
      @notification_file.name = notification_file_params[:uploaded_file].original_filename

      if @notification_file.save
        redirect_to responsible_person_notifications_path(@responsible_person)
      else
        render :new
      end

    else
      @notification_file.errors.add :uploaded_file, "No file selected"
      render :new
    end
  end

  def destroy
    NotificationFile.delete(params[:id])
    redirect_to responsible_person_notifications_path(@responsible_person)
  end

  def destroy_all
    @responsible_person.notification_files.where(user_id: current_user.id).where.not(upload_error: nil).delete_all
    redirect_to responsible_person_notifications_path(@responsible_person)
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification_file
    @notification_file = NotificationFile.new(notification_file_params)
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_file_params
    if params.has_key?(:notification_file)
      params.require(:notification_file).permit(:name, :uploaded_file)
    end
  end
end
