class ResponsiblePersons::NotificationsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :validate_responsible_person
  before_action :set_notification, only: %i[show]

  def index
    @registered_notifications = get_registered_notifications(20)
    respond_to do |format|
      format.html
      format.csv do
        @notifications = NotificationsDecorator.new(@responsible_person.notifications.completed.order(notification_complete_at: :desc))
        render csv: @notifications, filename: "all-notifications-#{Time.zone.now.to_fs(:db)}"
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

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_notification
    @notification = Notification.where.not(state: :deleted).find_by! reference_number: params[:reference_number]
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
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

  def search_params
    if params[:notification_search_form]
      params.fetch(:notification_search_form, {}).permit(:q,
                                                         { date_from: %i[day month year] },
                                                         { date_to: %i[day month year] },
                                                         :sort_by)
    elsif params[:ingredient_search_form]
      params.fetch(:ingredient_search_form, {}).permit(:q,
                                                       { date_from: %i[day month year] },
                                                       { date_to: %i[day month year] },
                                                       :group_by,
                                                       :sort_by,
                                                       :exact_or_any_match)
    end
  end
  helper_method :search_params
end
