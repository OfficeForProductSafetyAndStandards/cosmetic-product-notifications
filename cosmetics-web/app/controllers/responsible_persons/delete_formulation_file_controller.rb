class ResponsiblePersons::DeleteFormulationFileController < SubmitApplicationController
  before_action :set_notification, :set_component

  def destroy
    @component.formulation_file.purge
    redirect_back fallback_location: responsible_person_notification_draft_path(@notification.responsible_person, @notification)
  end

private

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_component
    @component = Component.find(params[:component_id])
    @notification = @component.notification

    return redirect_to responsible_person_notification_path(@component.notification.responsible_person, @component.notification) if @component&.notification&.notification_complete?

    authorize @component.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @component.notification.is_multicomponent? ? @component.name : "the product"
  end
end
