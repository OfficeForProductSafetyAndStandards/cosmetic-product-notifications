class ResponsiblePersons::NotificationsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :validate_responsible_person
  before_action :set_paper_trail_whodunnit

  def index
    @registered_notifications = get_registered_notifications(20)
    respond_to do |format|
      format.html
      format.csv do
        @notifications = NotificationsDecorator.new(@registered_notifications.except(:limit, :offset))
        render csv: @notifications, filename: "all-notifications-#{Time.zone.now.to_fs(:db)}"
      end
    end
  end

  def archived
    @registered_notifications = get_registered_archived_notifications(20)
    respond_to do |format|
      format.html
      format.csv do
        @notifications = NotificationsDecorator.new(@registered_notifications.except(:limit, :offset))
        render csv: @notifications, filename: "all-archived-notifications-#{Time.zone.now.to_fs(:db)}"
      end
    end
  end

  def show
    @notification = Notification.where.not(state: :deleted).find_by!(reference_number: params[:reference_number])
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
    @archive_history = @notification.versions_with_name
  end

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

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification.notification_complete? || @notification.archived?

    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy

    if params[:submit_failed]
      add_image_upload_errors
    end
  end

  def choose_archive_reason
    @notification = Notification.completed.find_by!(reference_number: params[:notification_reference_number])
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def archive
    @notification = Notification.completed.find_by!(reference_number: params[:notification_reference_number])
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy

    @notification.assign_attributes(archive_params)
    return render "choose_archive_reason" unless @notification.valid?(:archive)

    # This transition does not save automatically since AASM will save via paper trail
    @notification.archive

    flash[:success_banner] = {
      heading: "#{@notification.product_name} (#{@notification.reference_number_for_display}) has been archived.",
      body: "View your <a href=\"#{responsible_person_archived_notifications_path(@notification.responsible_person)}\">archived notifications</a> for any amendments.",
    }

    redirect_to responsible_person_notifications_path(@notification.responsible_person)
  end

  def unarchive
    @notification = Notification.archived.find_by!(reference_number: params[:notification_reference_number])
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy

    # This transition does not save automatically since AASM will save via paper trail
    @notification.unarchive

    flash[:success_banner] = {
      heading: "#{@notification.product_name} (#{@notification.reference_number_for_display}) has been unarchived.",
      body: "",
    }

    redirect_to responsible_person_notifications_path(@notification.responsible_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def get_registered_notifications(page_size)
    @responsible_person.notifications
      .completed
      .order(notification_complete_at: :desc)
      .page(params[:page]).per(page_size)
  end

  def get_registered_archived_notifications(page_size)
    @responsible_person.notifications
      .archived
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

  def archive_params
    params.fetch(:notification, {})
      .permit(:archive_reason)
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
