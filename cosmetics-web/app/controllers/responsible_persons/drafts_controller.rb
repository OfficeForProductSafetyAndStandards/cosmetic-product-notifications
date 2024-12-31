class ResponsiblePersons::DraftsController < SubmitApplicationController
  before_action :set_notification, except: %i[index new]
  before_action :set_responsible_person

  def index
    @unfinished_notifications = get_unfinished_notifications(20)
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
    unless @notification.submit_notification!
      flash[:alert] = "Notification could not be submitted"
      redirect_to edit_responsible_person_notification_path(@responsible_person, @notification)
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def set_notification
    @notification = Notification.includes(components: :associated_records).find_by(reference_number: params[:notification_reference_number])
    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete? || @notification&.archived?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def get_unfinished_notifications(page_size)
    @responsible_person.notifications
                       .where(state: NotificationStateConcern::DISPLAYABLE_INCOMPLETE_STATES)
                       .where.not(reference_number: nil, product_name: nil)
                       .order(updated_at: :desc)
                       .page(params[:page]).per(page_size)
  end
end
