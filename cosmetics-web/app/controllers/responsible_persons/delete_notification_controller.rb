class ResponsiblePersons::DeleteNotificationController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :validate_responsible_person
  before_action :set_notification

  def delete; end

  def destroy
    unless params[:confirmation] == "yes"
      @notification.errors.add(:confirmation, "Select yes if you want to delete this #{@notification.notification_complete? ? 'notification' : 'draft'}")
      return render(:delete)
    end

    NotificationDeleteService.new(@notification, current_user).call

    tab = @notification.notification_complete? ? "notified" : "incomplete"
    redirect_to responsible_person_notifications_path(@responsible_person, tab: tab), confirmation: "#{@notification.deleted_notification.product_name} notification deleted"
  end

private

  def current_operation
    SecondaryAuthentication::Operations::DELETE_NOTIFICATION
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?, policy_class: ResponsiblePersonPolicy
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:reference_number]
    authorize @notification, :destroy?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
