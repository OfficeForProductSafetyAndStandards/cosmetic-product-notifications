class ResponsiblePersons::DraftsController < SubmitApplicationController
  before_action :set_notification, except: :new
  before_action :set_responsible_person

  def show; end

  def new
    @notification = Notification.new
    render "show"
  end

  def add_component
    component = @notification.components.create
    @notification.update_state(NotificationStateConcern::READY_FOR_COMPONENTS, only_downgrade: true)
    redirect_to new_responsible_person_notification_component_build_path @notification.responsible_person, @notification, component
  end

  def add_nano_material
    nano = @notification.nano_materials.create
    ne = nano.nano_elements.create
    @notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
    redirect_to new_responsible_person_notification_nanomaterial_build_path @notification.responsible_person, @notification, ne
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
