class FormulationUploadController < ApplicationController
    before_action :set_models

    def new
    end

    def create
        file_upload = params[:formulation_file]
        @component.formulation_file.attach(file_upload)
        redirect_to formulation_upload_responsible_person_notification_path(@responsible_person, @notification)
    end

    private

    def set_models
        @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
        @notification = Notification.find_by reference_number: params[:notification_reference_number]
        @component = Component.find(params[:component_id])
    end
end
