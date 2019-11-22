class NanomaterialNotificationsController < ApplicationController
  before_action :set_responsible_person_from_url, only: %w[index new create]

  before_action :set_nanomaterial_notification_from_url, only: %i[notified_to_eu update_notified_to_eu upload_file update_file review name update_name submit confirmation_page]

  before_action :redirect_to_confirmation_page_if_submitted, only: %i[notified_to_eu update_notified_to_eu upload_file update_file review name update_name submit]

  def index; end

  def new
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.new
    @form_url = responsible_person_nanomaterials_path(@responsible_person)
    @form_method = :post
    render "name"
  end

  def create
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.new
    @nanomaterial_notification.name = params[:nanomaterial_notification][:name]
    @nanomaterial_notification.user_id = current_user.id

    if @nanomaterial_notification.save(context: :add_name)
      redirect_to notified_to_eu_nanomaterial_path(@nanomaterial_notification)
    else
      @form_url = responsible_person_nanomaterials_path(@responsible_person)
      @form_method = :post
      render "name"
    end
  end

  def name
    @form_url = name_nanomaterial_path(@nanomaterial_notification)
    @form_method = :patch
  end

  def update_name
    @nanomaterial_notification.name = params[:nanomaterial_notification][:name]

    if @nanomaterial_notification.save(context: :add_name)
      redirect_to review_nanomaterial_path(@nanomaterial_notification)
    else
      @form_url = name_nanomaterial_path(@nanomaterial_notification)
      @form_method = :patch

      render "name"
    end
  end

  def notified_to_eu; end

  def update_notified_to_eu
    if @nanomaterial_notification.update_with_context(eu_notification_params, :eu_notification)
      redirect_to upload_file_nanomaterial_path(@nanomaterial_notification)
    else
      render "notified_to_eu"
    end
  end

  def upload_file; end

  def update_file
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
    @nanomaterial_notification.submit!

    redirect_to confirmation_nanomaterial_path(@nanomaterial_notification)
  end

  def confirmation_page
    if !@nanomaterial_notification.submitted?
      redirect_to(review_nanomaterial_path(@nanomaterial_notification)) && return
    end

    render "confirmation_page"
  end

private

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

  def set_responsible_person_from_url
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end
end
