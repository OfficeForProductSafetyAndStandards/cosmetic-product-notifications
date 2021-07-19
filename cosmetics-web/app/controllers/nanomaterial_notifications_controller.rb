class NanomaterialNotificationsController < SubmitApplicationController
  PER_PAGE = 20

  before_action :set_responsible_person, only: %w[index new create]
  before_action :validate_responsible_person

  before_action :set_nanomaterial_notification_from_url, only: %i[show notified_to_eu update_notified_to_eu upload_file update_file review name update_name submit confirmation_page]

  before_action :redirect_to_confirmation_page_if_submitted, only: %i[notified_to_eu update_notified_to_eu upload_file update_file review name update_name submit]

  def index
    @nanomaterial_notifications = @responsible_person
                                    .nanomaterial_notifications
                                    .where.not(submitted_at: nil)
                                    .order(submitted_at: :desc)

    respond_to do |format|
      format.html do
        @nanomaterial_notifications = @nanomaterial_notifications.paginate(page: params[:page], per_page: PER_PAGE)
      end
      format.csv do
        @notifications = NanomaterialNotificationsDecorator.new(@nanomaterial_notifications)
        render csv: @notifications, filename: "all-nanomaterial-notifications-#{Time.zone.now.to_s(:db)}"
      end
    end
  end

  def show; end

  def new
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.new
    @previous_page_path = back_link_path_for(:name)
    @form_url = responsible_person_nanomaterials_path(@responsible_person)
    @form_method = :post
    render "name"
  end

  def create
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.new(
      name: params[:nanomaterial_notification][:name],
      user_id: current_user.id,
    )
    @previous_page_path = back_link_path_for(:name)

    if @nanomaterial_notification.save(context: :add_name)
      redirect_to notified_to_eu_nanomaterial_path(@nanomaterial_notification)
    else

      @form_url = responsible_person_nanomaterials_path(@responsible_person)
      @form_method = :post
      render "name"
    end
  end

  def name
    @previous_page_path = back_link_path_for(:name)
    @form_url = name_nanomaterial_path(@nanomaterial_notification)
    @form_method = :patch
  end

  def update_name
    @nanomaterial_notification.name = params[:nanomaterial_notification][:name]
    @previous_page_path = back_link_path_for(:name)

    if @nanomaterial_notification.save(context: :add_name)

      if @nanomaterial_notification.submittable?
        redirect_to review_nanomaterial_path(@nanomaterial_notification)
      else
        redirect_to notified_to_eu_nanomaterial_path(@nanomaterial_notification)
      end
    else

      @form_url = name_nanomaterial_path(@nanomaterial_notification)
      @form_method = :patch

      render "name"
    end
  end

  def notified_to_eu
    @previous_page_path = back_link_path_for(:notified_to_eu)
  end

  def update_notified_to_eu
    @nanomaterial_notification.eu_notified = params[:eu_notified]
    @nanomaterial_notification.notified_to_eu_on = params[:notified_to_eu_on]
    @previous_page_path = back_link_path_for(:notified_to_eu)

    if @nanomaterial_notification.save(context: :eu_notification)

      if @nanomaterial_notification.submittable?
        redirect_to review_nanomaterial_path(@nanomaterial_notification)
      else
        redirect_to upload_file_nanomaterial_path(@nanomaterial_notification)
      end
    else
      render "notified_to_eu"
    end
  end

  def upload_file
    @previous_page_path = back_link_path_for(:file)
  end

  def update_file
    @previous_page_path = back_link_path_for(:file)

    file = params.fetch(:nanomaterial_notification, {})[:file]

    if file
      @nanomaterial_notification.file.attach(file)
    end

    if @nanomaterial_notification.save(context: :upload_file)
      redirect_to review_nanomaterial_path(@nanomaterial_notification)
    else
      render "upload_file"
    end
  end

  def review; end

  def submit
    if @nanomaterial_notification.valid?(%i[add_name eu_notification upload_file])
      @nanomaterial_notification.submit!
      redirect_to confirmation_nanomaterial_path(@nanomaterial_notification)
    else
      render "review"
    end
  end

  def confirmation_page
    unless @nanomaterial_notification.submitted?
      redirect_to(review_nanomaterial_path(@nanomaterial_notification)) && return
    end

    render "confirmation_page"
  end

private

  def back_link_path_for(step)
    if @nanomaterial_notification.submittable?
      review_nanomaterial_path(@nanomaterial_notification)
    else
      case step
      when :name
        responsible_person_nanomaterials_path(@responsible_person)
      when :notified_to_eu
        name_nanomaterial_path(@nanomaterial_notification)
      when :file
        notified_to_eu_nanomaterial_path(@nanomaterial_notification)
      end
    end
  end

  def eu_notification_params
    params.permit(:eu_notified, :notified_to_eu_on)
  end

  def redirect_to_confirmation_page_if_submitted
    if @nanomaterial_notification.submitted?
      redirect_to(confirmation_nanomaterial_path(@nanomaterial_notification)) && return
    end
  end

  def set_nanomaterial_notification_from_url
    @nanomaterial_notification = NanomaterialNotification.find(params[:id])
    @responsible_person = @nanomaterial_notification.responsible_person
    authorize @responsible_person, :show?
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end
end
