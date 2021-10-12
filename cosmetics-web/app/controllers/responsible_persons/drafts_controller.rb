class ResponsiblePersons::DraftsController < SubmitApplicationController
  before_action :set_notification, only: %i[index]

  def index
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
