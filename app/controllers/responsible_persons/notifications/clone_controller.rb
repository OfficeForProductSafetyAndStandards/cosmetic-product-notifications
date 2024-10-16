class ResponsiblePersons::Notifications::CloneController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :set_notification

  def new
    @new_notification = Notification.new
  end

  def create
    @new_notification = @responsible_person.notifications.new(notification_params)

    if @new_notification.save(context: :cloning)
      NotificationCloner::Base.clone(@notification, @new_notification)
      redirect_to confirm_responsible_person_notification_clone_path(@responsible_person, @notification, cloned_notification_reference_number: @new_notification.reference_number)
    else
      render "new"
    end
  end

  def confirm
    @new_notification = @responsible_person.notifications.find_by reference_number: params[:cloned_notification_reference_number]
  end

private

  def set_notification
    @notification = Notification.where.not(state: :deleted).find_by! reference_number: params[:notification_reference_number]
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def notification_params
    params.fetch(:notification, {})
      .permit(:product_name)
  end
end
