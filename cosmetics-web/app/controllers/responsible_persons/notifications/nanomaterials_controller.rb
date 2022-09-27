class ResponsiblePersons::Notifications::NanomaterialsController < SubmitApplicationController
  before_action :set_notification

  def new
    @nano_material = NanoMaterial.new
  end

  def create
    @nano_material = NanoMaterial.new(inci_name: params.dig(:nano_material, :inci_name), notification: @notification)

    if @nano_material.save(context: :add_nanomaterial_name)
      @notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
      redirect_to responsible_person_notification_nanomaterial_build_path(
        @notification.responsible_person,
        @notification,
        @nano_material,
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
end
