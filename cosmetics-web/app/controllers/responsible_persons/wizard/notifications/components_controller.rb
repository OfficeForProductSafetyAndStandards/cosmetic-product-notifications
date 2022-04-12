class ResponsiblePersons::Wizard::Notifications::ComponentsController < SubmitApplicationController
  before_action :set_notification

  def new
    @component = Component.new
  end

  def create
    @component = @notification.components.new(component_params)

    if @component.save(context: :add_component_name)
      @notification.update_state(NotificationStateConcern::READY_FOR_COMPONENTS, only_downgrade: true)
      redirect_to responsible_person_notification_component_build_path(
        @notification.responsible_person,
        @notification,
        @component,
        first_build_step_after_name,
      )
    else
      render "new"
    end
  end

private

  def first_build_step_after_name
    @component.notification.nano_materials.present? ? :select_nanomaterials : :number_of_shades
  end

  # Duplicated from WizardConcern
  def set_notification
    @notification ||= Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def component_params
    params.fetch(:component, {}).permit(:name)
  end
end
