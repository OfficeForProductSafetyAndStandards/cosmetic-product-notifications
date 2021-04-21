class ResponsiblePersons::ContactPersonsController < SubmitApplicationController
  EDIT_FIELD_VIEW = {
    "name" => :edit_name,
    "email_address" => :edit_email_address,
    "phone_number" => :edit_phone_number,
  }.freeze

  skip_before_action :create_or_join_responsible_person
  before_action :set_responsible_person
  before_action :set_contact_person

  def new; end

  def create
    if @contact_person.save
      redirect_to responsible_person_notifications_path(@responsible_person)
    else
      render :new
    end
  end

  def edit
    view = EDIT_FIELD_VIEW[params[:field]]
    return redirect_to responsible_person_path(@responsible_person) unless view

    render view
  end

  def update
    field = contact_person_params.keys.first
    if @contact_person.update(contact_person_params)
      redirect_to responsible_person_path(@responsible_person),
                  confirmation: "Contact person #{field.humanize(capitalize: false)} changed successfully"
    else
      render EDIT_FIELD_VIEW[field]
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
end
