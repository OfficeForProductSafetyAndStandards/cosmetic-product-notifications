class ResponsiblePersons::NotificationFilesController < ApplicationController
  before_action :set_notification_file
  before_action :set_responsible_person

  def new
    @notification_file = NotificationFile.new
  end

  def create
    @notification_file = NotificationFile.new(notification_file_params)

    if notification_file_params && notification_file_params[:uploaded_file]
      @notification_file.name = notification_file_params[:uploaded_file].original_filename
      @notification_file.responsible_person = @responsible_person
      @notification_file.user_id = current_user.id
      @notification_file.uploaded_file.attach(notification_file_params[:uploaded_file])
    end

    respond_to do |format|
      if @notification_file.save
        format.html { redirect_to responsible_person_notifications_path(@responsible_person) }
        format.json { render :show, status: :created, location: @notification_file }
      else
        format.html { render :new }
        format.json { render json: @notification_file.errors, status: :unprocessable_entity }
      end
    end
  end

private

    # Use callbacks to share common setup or constraints between actions.
  def set_notification_file
    @notification_file = NotificationFile.find(params[:id])
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def notification_file_params
    if params.has_key?(:notification_file)
      params.require(:notification_file).permit(:name, :uploaded_file)
    end
  end
end
