class ResponsiblePersons::NotificationsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :validate_responsible_person
  before_action :set_notification, only: %i[show confirm]

  def index
    @erroneous_notification_files = []
    @pending_notification_files_count = 0

    @responsible_person.notification_files.where(user_id: current_user.id).each do |notification_file|
      if notification_file.upload_error
        @erroneous_notification_files << notification_file
      else
        @pending_notification_files_count += 1
      end
    end

    if session[:files_uploaded_count].to_i > @pending_notification_files_count
      @pending_notification_files_count = session[:files_uploaded_count]
      session[:files_uploaded_count] = nil
    end

    @unfinished_notifications = get_unfinished_notifications

    @registered_notifications = get_registered_notifications(20)
    respond_to do |format|
      format.html
      format.csv do
        @notifications = NotificationsDecorator.new(@responsible_person.notifications.completed.order(:created_at))
        render csv: @notifications, filename: "all-notifications-#{Time.zone.now.to_s(:db)}"
      end
    end
  end

  def show; end

  def new
    @notification = Notification.create(responsible_person: @responsible_person)

    redirect_to new_responsible_person_notification_product_path(@responsible_person, @notification)
  end

  # Check your answers page
  def edit
    @notification = Notification.where.not(state: :deleted).find_by! reference_number: params[:reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification.notification_complete?

    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy

    @previous_page_path = previous_path_before_check_your_answers(@notification)

    if params[:submit_failed]
      add_image_upload_errors
    end
  end

  def confirm
    if @notification.submit_notification!
      redirect_to responsible_person_notifications_path(@responsible_person), confirmation: "#{@notification.product_name} notification submitted"
    else
      redirect_to edit_responsible_person_notification_path(@responsible_person, @notification, submit_failed: true)
    end
  end

private

  # Returns the path for the page the user must have been on prior to
  # the 'Check your answers' page. This varies depending on the route
  # through the various sets of questions.
  def previous_path_before_check_your_answers(notification)
    if notification.via_zip_file?
      # Incomplete notifications dashboard
      responsible_person_notifications_path(notification.responsible_person, anchor: "incomplete")
    elsif notification.is_multicomponent?
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
      .where.not(state: %i[notification_complete])
      .where("reference_number IS NOT NULL")
      .where("product_name IS NOT NULL")
      .order("updated_at DESC")
  end

  def get_registered_notifications(page_size)
    @responsible_person.notifications
      .completed
      .paginate(page: params[:page], per_page: page_size)
      .order(notification_complete_at: :desc)
  end

  def add_image_upload_errors
    if @notification.images_failed_anti_virus_check?
      @notification.errors.add :image_uploads, "failed anti virus check"
    end

    if @notification.images_pending_anti_virus_check?
      @notification.errors.add :image_uploads, "waiting for files to pass anti virus check. Refresh to update"
    end
  end
end
