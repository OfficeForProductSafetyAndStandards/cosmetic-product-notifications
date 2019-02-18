class ResponsiblePersons::AccountWizardController < ApplicationController
  include Wicked::Wizard

  steps :select_type, :enter_details

  skip_before_action :create_or_join_responsible_person
  before_action :set_responsible_person, only: %i[show update verify_email]
  before_action :store_responsible_person, only: %i[update]

  # GET /responsible_persons/account/create_or_join_existing
  def create_or_join_existing
    clear_session
    case params[:option]
    when "create_new"
      redirect_to wizard_path(:select_type)
    when "join_existing"
      redirect_to join_existing_account_index_path
    else
      @nothing_selected = true if params[:commit].present?
    end
  end

  # GET /responsible_persons/account/join_existing
  def join_existing; end

  # GET /responsible_persons/account/:step
  def show
    render_wizard
  end

  # GET /responsible_persons/account/verify_email
  def verify_email; end

  # PATCH/PUT /responsible_persons/account/:step
  def update
    case step
    when :enter_details
      if responsible_person_saved?
        key = @responsible_person.email_verification_keys.create

        NotifyMailer.send_responsible_person_verification_email(
          @responsible_person.email_address,
          current_user.full_name,
          responsible_person_email_verification_key_path(@responsible_person, key)
        ).deliver_later

        redirect_to finish_wizard_path
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

  def finish_wizard_path
    @responsible_person = current_user.responsible_persons.first
    responsible_person_email_verification_keys_path(@responsible_person)
  end

private

  def clear_session
    session[:responsible_person] = nil
  end

  def set_responsible_person
    @responsible_person = ResponsiblePerson.new(responsible_person_params)
  end

  def store_responsible_person
    session[:responsible_person] = @responsible_person.attributes if responsible_person_valid?
  end

  def responsible_person_valid?
    @responsible_person.valid?(step)
  end

  def responsible_person_saved?
    return false unless responsible_person_valid?

    @responsible_person.add_user(User.current)
    @responsible_person.save
  end

  def responsible_person_params
    session_params.merge(request_params)
  end

  def session_params
    session.fetch(:responsible_person, {})
  end

  def request_params
    params.fetch(:responsible_person, {}).permit(
      :account_type,
      :name,
      :companies_house_number,
      :email_address,
      :phone_number,
      :address_line_1,
      :address_line_2,
      :city,
      :county,
      :postal_code
    )
  end
end
