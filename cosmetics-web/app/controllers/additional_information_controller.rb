class AdditionalInformationController < ApplicationController
  before_action :set_notification, only: %i[index]

  def index
    if @notification.formulation_required?
      component = @notification.components.find(&:formulation_required?)
      return redirect_to new_responsible_person_notification_component_formulation_path(@notification.responsible_person, @notification, component)
    else
      @notification.formulation_file_uploaded!
    end

    if @notification.images_required?
      return redirect_to new_responsible_person_notification_product_image_upload_path(@notification.responsible_person, @notification)
    end

    redirect_to edit_responsible_person_notification_path(@notification.responsible_person, @notification)
  end

private

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]
    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
