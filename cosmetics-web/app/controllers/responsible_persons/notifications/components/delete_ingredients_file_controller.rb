class ResponsiblePersons::Notifications::Components::DeleteIngredientsFileController < SubmitApplicationController
  before_action :set_component

  def destroy
    @component.ingredients.delete_all
    @component.ingredients_file.purge
    redirect_to responsible_person_notification_component_build_path(@notification.responsible_person, @notification, @component, :upload_ingredients_file)
  end

private

  def set_component
    @component = Component.find(params[:component_id])
    @notification = @component.notification

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
