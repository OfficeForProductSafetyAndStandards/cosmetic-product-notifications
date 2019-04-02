class FormulationUploadController < ApplicationController
  before_action :set_models

  def new; end

  def create
    if params[:formulation_file].present?
      file_upload = params[:formulation_file]
      @component.formulation_file.attach(file_upload)

      if @component.save
        redirect_to responsible_person_notification_additional_information_index_path(@component.notification.responsible_person, @component.notification)
      else
        @component.formulation_file.purge
        @component.errors.messages[:formulation_file].map(&method(:add_error))
        render :new
      end
    else
      add_error "No file selected"
      render :new
    end
  end

private

  def add_error error_message
    @error_list.push(text: error_message, href: "#formulation_file")
  end

  def set_models
    @error_list = []
    @component = Component.find(params[:component_id])
    @notification = @component.notification
    @responsible_person = @notification.responsible_person
    authorize @component.notification, policy_class: ResponsiblePersonNotificationPolicy
  end
end
