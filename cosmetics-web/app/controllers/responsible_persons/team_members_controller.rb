class ResponsiblePersons::TeamMembersController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :authorize_responsible_person, only: %i[index new create]
  before_action :validate_responsible_person, except: %i[join sign_out_before_joining]

  skip_before_action :authenticate_user!, only: :join
  skip_before_action :create_or_join_responsible_person
  skip_before_action :require_secondary_authentication, only: %i[index join sign_out_before_joining]

  def index; end

  def new
    @invite_member_form = ResponsiblePersons::InviteMemberForm.new(responsible_person: @responsible_person)
  end

  def create
    @invite_member_form = ResponsiblePersons::InviteMemberForm.new(
      invite_member_form_params.merge(responsible_person: @responsible_person),
    )

    if @invite_member_form.valid?
      create_invitation!
      send_invite_email
      redirect_to(responsible_person_team_members_path(@responsible_person),
                  confirmation: "Invite sent to #{@invite_member_form.email}")
    else
      render :new
    end
  end

  def join
    pending_request = PendingResponsiblePersonUser.find_by!(invitation_token: params[:invitation_token])
    return render("invitation_expired") if pending_request.expired?

    user = SubmitUser.find_by(email: pending_request.email_address)
    return render("signed_as_another_user", locals: { user: user }) if signed_as_another_user?(pending_request)

    if user&.account_security_completed?
      authenticate_user!
      responsible_person = pending_request.responsible_person
      user_joins_responsible_person(user, responsible_person)
      redirect_to responsible_person_notifications_path(responsible_person)
    else
      login_user_from_invitation?(pending_request, user)
      redirect_to registration_new_account_security_path
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def resend_invitation
    @invitation = @responsible_person.pending_responsible_person_users.find(params[:id])

    ActiveRecord::Base.transaction do
      @invitation.refresh_token_expiration!
      @invitation.update!(inviting_user: current_user)
      send_invite_email
    end

    redirect_to responsible_person_team_members_path(@responsible_person), confirmation: "Invite sent to #{@invitation.email_address}"
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

  def invite_member_form_params
    params.require(:invite_member_form).permit(:name, :email)
  end

  def create_invitation!
    # If an existing user is invited, the name of the existing user will be used instead of the one provided in the form.
    name = SubmitUser.find_by(email: @invite_member_form.email)&.name || @invite_member_form.name
    @invitation = @responsible_person.pending_responsible_person_users.create!(
      name: name,
      email_address: @invite_member_form.email,
      inviting_user: current_user,
    )
  end

  def send_invite_email
    SubmitNotifyMailer.send_responsible_person_invite_email(
      @responsible_person,
      @invitation,
      current_user.name,
    ).deliver_later
  end

  def signed_as_another_user?(invitation)
    current_user && !current_user.email.casecmp(invitation.email_address).zero?
  end

  def user_joins_responsible_person(user, responsible_person)
    responsible_person.add_user(user)
    PendingResponsiblePersonUser.where(email_address: user.email).delete_all
    set_current_responsible_person(responsible_person)
  end

  def login_user_from_invitation?(pending_request, user)
    # User will be already set at this point if was created but not completed security details
    user ||= SubmitUser.new(email: pending_request.email_address, name: pending_request.name).tap do |u|
      u.dont_send_confirmation_instructions!
      u.save(validate: false)
    end
    bypass_sign_in(user)
    session[:registered_from_responsible_person_invitation_id] = pending_request.id
  end

  # See: SecondaryAuthenticationConcern
  def current_operation
    SecondaryAuthentication::Operations::INVITE_USER
  end
end
