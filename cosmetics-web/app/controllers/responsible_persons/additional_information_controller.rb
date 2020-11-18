class ResponsiblePersons::AdditionalInformationController < SubmitApplicationController
  before_action :set_notification, only: %i[index]

  def index
    if @notification.nano_material_required?
      component = @notification.components.order(:id).find(&:nano_material_required?)
      nano_element = component.nano_material.nano_elements.order(:id).find(&:required?)
      return redirect_to new_responsible_person_notification_component_nanomaterial_build_path(@notification.responsible_person, @notification, component, nano_element)
    elsif @notification.formulation_required?
      component = @notification.components.order(:id).find(&:formulation_required?)
      return redirect_to new_responsible_person_notification_component_formulation_path(@notification.responsible_person, @notification, component)
    else
      @notification.formulation_file_uploaded!
    end

    if @notification.images_required_and_missing?
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
