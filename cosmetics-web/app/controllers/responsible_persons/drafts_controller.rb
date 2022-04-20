class ResponsiblePersons::DraftsController < SubmitApplicationController
  before_action :set_notification, except: :new
  before_action :set_responsible_person

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
    unless @notification.submit_notification!
      redirect_to edit_responsible_person_notification_path(@responsible_person, @notification, submit_failed: true)
    end
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
