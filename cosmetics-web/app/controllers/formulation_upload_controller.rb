class FormulationUploadController < ApplicationController
  before_action :set_models

  def new; end

  def create
    if params[:formulation_file].present?
      file_upload = params[:formulation_file]
      @component.formulation_file.attach(file_upload)

      if @component.save
        redirect_to upload_formulation_responsible_person_notification_path(@component.notification.responsible_person, @component.notification)
      else
        @component.formulation_file.purge
        @error_list = @component.errors.messages[:formulation_file].map { |message| { text: message } }
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
    @component = Component.find(params[:component_id])
    @notification = @component.notification
    @responsible_person = @notification.responsible_person
    authorize @component.notification, policy_class: ResponsiblePersonNotificationPolicy
  end
end
