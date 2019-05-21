class ResponsiblePersons::ContactPersonsController < ApplicationController
  skip_before_action :create_or_join_responsible_person
  before_action :set_responsible_person
  before_action :set_contact_person

  def show; end

  def new; end

  def create
    if @contact_person.save
      redirect_contact_person
    else
      render :new
    end
  end

  def edit; end

  def update
    if @contact_person.update(contact_person_params)
      remove_contact_person_email_verification_key
      redirect_contact_person
    else
      render :edit
    end
  end

  def resend_email
    remove_contact_person_email_verification_key
    send_verification_email

    redirect_to responsible_person_contact_person_path(@responsible_person, @contact_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_contact_person
    @contact_person = if params[:id]
                        @responsible_person.contact_persons.find(params[:id])
                      else
                        @responsible_person.contact_persons.build(contact_person_params)
                      end
  end

  def contact_person_params
    params.fetch(:contact_person, {}).permit(
      :email_address,
      :phone_number,
      :name
    )
  end

  def send_verification_email
    NotifyMailer.send_contact_person_verification_email(
      @contact_person.id,
      @contact_person.name,
      @contact_person.email_address,
      @responsible_person.name,
      User.current.name
    ).deliver_later
  end

  def redirect_contact_person
    if @contact_person.email_verified?
      redirect_to responsible_person_path(@responsible_person)
    else
      send_verification_email
      redirect_to responsible_person_contact_person_path(@responsible_person, @contact_person)
    end
  end

  def remove_contact_person_email_verification_key
    EmailVerificationKey.where(contact_person: @contact_person).delete_all
  end
end
