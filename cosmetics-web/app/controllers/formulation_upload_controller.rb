class FormulationUploadController < ApplicationController
  before_action :set_models

  def new; end

  def create
    if params[:formulation_file].present?
      file_upload = params[:formulation_file]
      @component.formulation_file.attach(file_upload)

      if @component.save
        redirect_to formulation_upload_responsible_person_notification_path(@responsible_person, @notification)
      else
        @component.formulation_file.purge
        @component.errors.messages[:formulation_file].each do |message|
          @error_list.push(text: message)
        end
        render :new
      end
    else
      @error_list.push(text: "No file selected")
      render :new
    end
  end

private

  def set_models
    @error_list = []
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    @notification = Notification.find_by reference_number: params[:notification_reference_number]
    @component = Component.find(params[:component_id])
  end
end
