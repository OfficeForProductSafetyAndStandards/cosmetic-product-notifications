class NanomaterialNotificationsController < ApplicationController
  before_action :set_responsible_person

  def index; end

  def new
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.new
  end

  def update_name
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])
    @nanomaterial_notification.iupac_name = params[:nanomaterial_notification][:iupac_name]

    if @nanomaterial_notification.save(context: :add_iupac_name)
      redirect_to review_responsible_person_nanomaterial_path(@responsible_person, @nanomaterial_notification)
    else
      render "name"
    end
  end

  def name
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])
  end

  def create
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.new
    @nanomaterial_notification.iupac_name = params[:nanomaterial_notification][:iupac_name]
    @nanomaterial_notification.user_id = current_user.id

    if @nanomaterial_notification.save(context: :add_iupac_name)
      redirect_to notified_to_eu_responsible_person_nanomaterial_path(@responsible_person, @nanomaterial_notification)
    else
      render "new"
    end
  end

  def notified_to_eu
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])
  end

  def update_notified_to_eu
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])


    if @nanomaterial_notification.update_with_context(eu_notification_params, :eu_notification)
      redirect_to upload_file_responsible_person_nanomaterial_path(@responsible_person, @nanomaterial_notification)
    else
      render "notified_to_eu"
    end
  end

  def upload_file
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])
  end

  def update_file
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])

    @nanomaterial_notification.file.attach(params[:nanomaterial_notification][:file])

    @nanomaterial_notification.save!

    redirect_to review_responsible_person_nanomaterial_path(@responsible_person, @nanomaterial_notification)
  end

  def review
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])
  end

  def submit
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])

    @nanomaterial_notification.submit!

    redirect_to confirmation_responsible_person_nanomaterial_path(@responsible_person, @nanomaterial_notification)
  end

  def confirmation_page
    @nanomaterial_notification = @responsible_person.nanomaterial_notifications.find(params[:id])
    render "confirmation_page"
  end

private

  def eu_notification_params
    params.permit(:eu_notified, :notified_to_eu_on)
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end
end
