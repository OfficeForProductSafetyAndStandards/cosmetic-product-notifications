class ResponsiblePersons::Notifications::NanomaterialsController < SubmitApplicationController
  PURPOSES_FORM_CLASS = ResponsiblePersons::Notifications::Nanomaterials::PurposesForm

  before_action :set_notification

  def new
    @purposes_form = PURPOSES_FORM_CLASS.new
  end

  def create
    @purposes_form = PURPOSES_FORM_CLASS.new(**purpose_params)
    return render "new" unless @purposes_form.valid?

    nano_material = NanoMaterial.new(purposes: @purposes_form.purposes, notification: @notification)

    if nano_material.save(context: :select_purposes)
      @notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
      redirect_to responsible_person_notification_nanomaterial_build_path(
        @notification.responsible_person,
        @notification,
        nano_material,
        :after_select_purposes_routing,
      )
    else
      render "new"
    end
  end

private

  def set_notification
    @notification ||= Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete? || @notification&.archived?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def purpose_params
    form_params = params.permit(purposes_form: [:purpose_type, *NanoMaterialPurposes.standard.map(&:name)])
                        .fetch(:purposes_form, {})

    { purposes: form_params.select { |_, v| v == "1" }.keys, purpose_type: form_params[:purpose_type] }
  end
end
