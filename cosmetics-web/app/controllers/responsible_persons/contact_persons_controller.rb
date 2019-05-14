class ResponsiblePersons::ContactPersonsController < ApplicationController
  skip_before_action :create_or_join_responsible_person
  before_action :set_responsible_person
  before_action :set_contact_person, only: %i[new create]
  before_action :find_contact_person, only: %i[edit update show]

  def show; end
  #write redirect logic here in show

  def new; end

  def create
    if contact_person_saved?
      send_verification_email
      redirect_to responsible_person_contact_person_path(@responsible_person, @contact_person)
    else
      render :new
    end
  end

  def edit; end

  def update
    @contact_person.update(contact_person_params)

    if contact_person_saved?
      send_verification_email
      redirect_to responsible_person_contact_person_path(@responsible_person, @contact_person)
    else
      render :edit
    end
  end

private

  def find_contact_person
    @contact_person = ContactPerson.find(params[:id])
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_contact_person
    @contact_person = @responsible_person.contact_persons.build(contact_person_params)
  end

  def contact_person_saved?
    return false unless @contact_person.valid?
    @contact_person.save
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
end
