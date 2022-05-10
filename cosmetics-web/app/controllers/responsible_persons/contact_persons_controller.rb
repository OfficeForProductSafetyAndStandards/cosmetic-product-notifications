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
      # After contact person creation we might like to go back to previous RP as
      # we don't want to switch to new RP
      # See also ResponsiblePerspon::AccountWizardController
      set_current_responsible_person_from_previous
      redirect_to responsible_person_path(current_responsible_person), confirmation: create_successful_message
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
    # As the edit pages have only one field per page, updates will come with a single field being updated.
    # Possible field values: "name", "email_address", "phone_number"
    field = contact_person_params.keys.first
    @contact_person.public_send("#{field}=", contact_person_params[field])

    changed = @contact_person.changed?
    if @contact_person.save
      redirect_to(responsible_person_path(@responsible_person), confirmation: confirmation_message(field, changed))
    else
      render EDIT_FIELD_VIEW[field]
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :update?
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

  def confirmation_message(field, changed)
    return unless changed # Don't set confirmation message when submitted value does not change the current value

    "Contact person #{field.humanize(capitalize: false)} changed successfully"
  end

  def create_successful_message
    if current_user.responsible_persons.count > 1
      "The new Responsible Person has been added to your list of Responsible Persons and can be selected as the Responsible Person."
    else
      "Success: The Responsible Person was created."
    end
  end
end
