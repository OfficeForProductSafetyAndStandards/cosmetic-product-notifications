class ResponsiblePersons::TeamMembersController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :authorize_responsible_person, only: :index
  before_action :validate_responsible_person, only: :index

  skip_before_action :authenticate_user!, only: :join
  skip_before_action :create_or_join_responsible_person
  skip_before_action :require_secondary_authentication

  def index; end

  def join
    invitation = PendingResponsiblePersonUser.find_by!(invitation_token: params[:invitation_token])
    return render("invitation_expired") if invitation.expired?

    user = SubmitUser.find_by(email: invitation.email_address) ||
      SubmitUser.find_by(new_email: invitation.email_address)
    return render("signed_as_another_user", locals: { user: user }) if signed_as_another_user?(invitation)

    if user&.account_security_completed?
      authenticate_user!
      responsible_person = invitation.responsible_person
      user_joins_responsible_person(user, responsible_person)
      user.confirm_new_email! if user.new_email == invitation.email_address
      redirect_to responsible_person_notifications_path(responsible_person)
    else
      login_user_from_invitation?(invitation, user)
      redirect_to registration_new_account_security_path
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def sign_out_before_joining
    sign_out
    redirect_to join_responsible_person_team_members_path(params[:responsible_person_id], invitation_token: params[:invitation_token])
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def authorize_responsible_person
    authorize @responsible_person, :show?
  end

  def signed_as_another_user?(invitation)
    current_user && !current_user.uses_email_address?(invitation.email_address)
  end

  def user_joins_responsible_person(user, responsible_person)
    responsible_person.add_user(user)
    PendingResponsiblePersonUser.where(email_address: user.email).delete_all
    set_current_responsible_person(responsible_person)
  end

  def login_user_from_invitation?(invitation, user)
    # User will be already set at this point if was created but not completed security details
    user ||= SubmitUser.new(email: invitation.email_address, name: invitation.name).tap do |u|
      u.dont_send_confirmation_instructions!
      u.save(validate: false)
    end
    bypass_sign_in(user)
    session[:registered_from_responsible_person_invitation_id] = invitation.id
  end

  # See: SecondaryAuthenticationConcern
  def current_operation
    SecondaryAuthentication::Operations::INVITE_USER
  end
end
