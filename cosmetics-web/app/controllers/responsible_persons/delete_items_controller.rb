class ResponsiblePersons::DeleteItemsController < SubmitApplicationController
  before_action :set_notification

  def show
    @form = NotificationWizard::DeleteComponentForm.new
  end

  def destroy
    @form = NotificationWizard::DeleteComponentForm.new(form_params.merge(notification: @notification))
    if @form.delete
      redirect_to responsible_person_notification_draft_path(@notification.responsible_person, @notification), confirmation: "The item was deleted"
    else
      render "show"
    end
  end

private

  def form_params
    params.require(:notification_wizard_delete_component_form).permit(:component_id)
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
