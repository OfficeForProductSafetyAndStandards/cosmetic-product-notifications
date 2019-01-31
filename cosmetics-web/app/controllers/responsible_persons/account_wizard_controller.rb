class ResponsiblePersons::AccountWizardController < ApplicationController
  include Wicked::Wizard

  steps :create_or_join_existing, :join_existing, :select_type, :enter_details

  skip_before_action :create_or_join_responsible_person
  before_action :set_responsible_person, only: %i[show update]
  before_action :store_responsible_person, only: %i[update]

  # GET /responsible_persons/account/step
  def show
    case step
    when :create_or_join_existing
      create_or_join_existing_responsible_person
    else
      render_wizard
    end
  end

  # PATCH/PUT /responsible_persons/account/step
  def update
    case step
    when :enter_details
      if responsible_person_saved?
        redirect_to responsible_person_path(@responsible_person)
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

  def create_or_join_existing_responsible_person
    clear_session
    case params[:option]
    when "create_new"
      redirect_to_next :select_type
    when "join_existing"
      redirect_to_next :join_existing
    else
      @nothing_selected = true if params[:commit].present?
      render_step :create_or_join_existing
    end
  end

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

    @responsible_person.add_team_member(current_user)
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
