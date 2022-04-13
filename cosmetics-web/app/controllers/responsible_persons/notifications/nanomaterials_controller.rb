class ResponsiblePersons::Notifications::NanomaterialsController < SubmitApplicationController
  before_action :set_notification

  def new
    @nano_element = NanoElement.new
  end

  def create
    @nano_element = NanoElement.new(nano_element_params.merge(nano_material: @notification.nano_materials.new))

    if @nano_element.save(context: :add_nanomaterial_name)
      @notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
      redirect_to responsible_person_notification_nanomaterial_build_path(
        @notification.responsible_person,
        @notification,
        @nano_element,
        :select_purposes,
      )
    else
      render "new"
    end
  end

private

  def set_notification
    @notification ||= Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def nano_element_params
    params.fetch(:nano_element, {}).permit(:inci_name)
  end
end
