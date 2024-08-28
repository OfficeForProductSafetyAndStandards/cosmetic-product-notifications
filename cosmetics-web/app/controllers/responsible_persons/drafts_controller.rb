class ResponsiblePersons::DraftsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :set_notification, except: %i[index new]

  def index
    @unfinished_notifications = @responsible_person.notifications.unfinished.page(params[:page]).per(20)
  end

  def show; end

  def new
    @notification = Notification.new
    render "show"
  end

  def review
    @notification.valid?(:accept_and_submit) if @notification.components_complete?
  end

  def declaration; end

  def accept
    if @notification.submit_notification!
      redirect_to responsible_person_notification_path(@responsible_person, @notification), notice: "Notification submitted successfully"
    else
      redirect_to edit_responsible_person_notification_path(@responsible_person, @notification), alert: "Notification could not be submitted"
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def set_notification
    @notification = @responsible_person.notifications.find_by!(reference_number: params[:notification_reference_number])

    if @notification.notification_complete? || @notification.archived?
      redirect_to responsible_person_notification_path(@notification.responsible_person, @notification)
    else
      authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    end
  end
end