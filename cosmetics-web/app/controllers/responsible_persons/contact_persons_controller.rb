class ResponsiblePersons::ContactPersonsController < ApplicationController
  skip_before_action :create_or_join_responsible_person
  before_action :set_responsible_person
  before_action :set_contact_person

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
      redirect_contact_person
    else
      render :edit
    end
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
      :name,
    )
  end

  def redirect_contact_person
    redirect_to responsible_person_notifications_path(@responsible_person)
  end
end
