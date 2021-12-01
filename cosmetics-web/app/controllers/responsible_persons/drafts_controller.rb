class ResponsiblePersons::DraftsController < SubmitApplicationController
  before_action :set_notification

  def index
  end

  def add_component
    @notification.components.create
    @notification.update_state('ready_for_components')
    redirect_to responsible_person_notification_draft_index_path @notification.responsible_person, @notification
  end

  def add_nano_material
    nano = @notification.nano_materials.create
    nano.nano_elements.create
    @notification.update_state('ready_for_nanomaterials')
    redirect_to responsible_person_notification_draft_index_path @notification.responsible_person, @notification
  end

private

  def responsible_person
    @notification&.responsible_person
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
