class ResponsiblePersons::AccountWizardController < SubmitApplicationController
  include Wicked::Wizard

  steps :pending_invitations, :overview, :create_or_join_existing, :join_existing, :select_type, :enter_details

  # Using directly the id parameter as'step' is set to nil at this point and 'if' condition gets ignored. Wicked Wizard magic...
  skip_before_action :has_accepted_declaration, if: -> { params[:id] == "pending_invitations" }
  skip_before_action :create_or_join_responsible_person
  before_action :pending_invitations, if: -> { step == :pending_invitations }
  before_action :clear_session, if: -> { step == :overview }
  before_action :set_responsible_person, only: %i[show update]
  before_action :responsible_persons_details_form, if: -> { step == :enter_details }
  before_action :store_responsible_person, only: %i[update]

  # GET /responsible_persons/account/:step
  def show
    render_wizard
  end

  # PATCH/PUT /responsible_persons/account/:step
  def update
    case step
    when :create_or_join_existing
      create_or_join_existing_account
    when :enter_details
      if responsible_person_saved?
        clear_session
        set_current_responsible_person(@responsible_person)
        redirect_to new_responsible_person_contact_person_path(@responsible_person)
      else
        render step
      end
    else
      if responsible_person_valid?
        redirect_to next_wizard_path
      else
        render step
      end
    end
  end

private

  def clear_session
    session.delete(:responsible_person)
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.new(responsible_person_params)
  end

  def responsible_persons_details_form
    @responsible_persons_details_form ||=
      ResponsiblePersons::DetailsForm.new(responsible_persons_details_form_params.merge(user: current_user))
  end

  def store_responsible_person
    session[:responsible_person] = @responsible_person.attributes if responsible_person_valid?
  end

  def responsible_person_valid?
    @responsible_person.valid?(step)
  end

  def responsible_person_saved?
    return false unless @responsible_persons_details_form.valid?

    @responsible_person.add_user(current_user)
    @responsible_person.save
  end

  def create_or_join_existing_account
    clear_session
    case params[:option]
    when "create_new"
      redirect_to wizard_path(:select_type)
    when "join_existing"
      redirect_to wizard_path(:join_existing)
    else
      @nothing_selected = true if params[:commit].present?
      render step
    end
  end

  def responsible_person_params
    responsible_person_session_params.merge(
      responsible_person_request_params.merge(
        responsible_persons_details_form_params,
      ),
    )
  end

  def responsible_person_session_params
    session.fetch(:responsible_person, {})
  end

  def responsible_person_request_params
    params.fetch(:responsible_person, {}).permit(:account_type)
  end

  def responsible_persons_details_form_params
    params.fetch(:responsible_persons_details_form, {}).permit(
      :name,
      :address_line_1,
      :address_line_2,
      :city,
      :county,
      :postal_code,
    )
  end
end
