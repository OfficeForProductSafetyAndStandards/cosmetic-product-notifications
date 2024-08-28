class ResponsiblePersons::DraftsController < SubmitApplicationController
  PAGE_SIZE = 20

  before_action :set_responsible_person
  before_action :load_notification, except: %i[index new]

  def index
    @unfinished_notifications = fetch_unfinished_notifications(PAGE_SIZE)
  end

  def show; end

  def new
    @notification = Notification.new
    render :show
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
    @responsible_person ||= ResponsiblePerson.includes(:notifications).find(params[:responsible_person_id])
  end

  def load_notification
    @notification ||= Notification.find_by(reference_number: params[:notification_reference_number])
    authorize_notification if @notification
  end

  def authorize_notification
    if notification_redirect_needed?
      redirect_to responsible_person_notification_path(@notification.responsible_person, @notification)
    else
      authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    end
  end

  def notification_redirect_needed?
    @notification&.notification_complete? || @notification&.archived?
  end

  def fetch_unfinished_notifications(limit)
    @responsible_person.notifications
                       .where(state: NotificationStateConcern::DISPLAYABLE_INCOMPLETE_STATES)
                       .where.not(reference_number: nil, product_name: nil)
                       .order(updated_at: :desc)
                       .limit(limit)
                       .page(params[:page])
  end
end
