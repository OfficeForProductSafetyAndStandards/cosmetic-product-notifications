class ResponsiblePersons::NotificationsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :validate_responsible_person
  before_action :set_notification, only: %i[show]

  def index
    @unfinished_notifications = get_unfinished_notifications
    @registered_notifications = get_registered_notifications(20)
    respond_to do |format|
      format.html
      format.csv do
        @notifications = NotificationsDecorator.new(@responsible_person.notifications.completed.order(notification_complete_at: :desc))
        render csv: @notifications, filename: "all-notifications-#{Time.zone.now.to_s(:db)}"
      end
    end
  end

  def show; end

  def new
    @notification = @responsible_person.notifications.new
  end

  def create
    @notification = @responsible_person.notifications.new(notification_params)
    if @notification.save
      redirect_to responsible_person_notification_product_path(@responsible_person, @notification, :add_internal_reference)
    else
      render "new"
    end
  end

  # Check your answers page
  def edit
    @notification = Notification.where.not(state: :deleted).find_by! reference_number: params[:reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification.notification_complete?

    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy

    if params[:submit_failed]
      add_image_upload_errors
    end
  end

private

  # Returns the path for the page the user must have been on prior to
  # the 'Check your answers' page. This varies depending on the route
  # through the various sets of questions.
  def previous_path_before_check_your_answers(notification)
    if notification.is_multicomponent?
      # Last page is the List of components
      responsible_person_notification_build_path(notification.responsible_person, notification, :add_new_component)
    else
      component = notification.components.first
      # Last question was either pH question or exact pH range for the component
      page = component.minimum_ph ? :ph : :select_ph_range
      responsible_person_notification_component_trigger_question_path(notification.responsible_person, notification, component, page)
    end
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_notification
    @notification = Notification.where.not(state: :deleted).find_by! reference_number: params[:reference_number]
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def get_unfinished_notifications
    @responsible_person.notifications
      .where("state IN (?)", NotificationStateConcern::DISPLAYABLE_INCOMPLETE_STATES)
      .where("reference_number IS NOT NULL")
      .where("product_name IS NOT NULL")
      .order("updated_at DESC")
  end

  def get_registered_notifications(page_size)
    @responsible_person.notifications
      .completed
      .order(notification_complete_at: :desc)
      .page(params[:page]).per(page_size)
  end

  def add_image_upload_errors
    if @notification.images_failed_anti_virus_check?
      @notification.errors.add :image_uploads, "failed anti virus check"
    end

    if @notification.images_pending_anti_virus_check?
      @notification.errors.add :image_uploads, "waiting for files to pass anti virus check. Refresh to update"
    end
  end

  def notification_params
    params.fetch(:notification, {})
      .permit(:product_name)
  end
end
