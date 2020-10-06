class ResponsiblePersons::TeamMembersController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :set_team_member, only: %i[new create]
  before_action :authorize_responsible_person, only: %i[new create]
  skip_before_action :authenticate_user!, only: :join
  skip_before_action :create_or_join_responsible_person
  skip_before_action :require_secondary_authentication, only: %i[index join]

  def index; end

  def new; end

  def create
    @responsible_person.save
    return render :new if @responsible_person.errors.any?

    send_invite_email
    redirect_to responsible_person_team_members_path(@responsible_person), confirmation: "Invite sent to #{team_member_params['email_address']}"
  end

  def join
    pending_request = PendingResponsiblePersonUser.find_by!(invitation_token: params[:invitation_token])
    return render("invitation_expired") if pending_request.expired?

    user = SubmitUser.find_by(email: pending_request.email_address)
    return render("signed_as_another_user", locals: { user: user }) if signed_as_another_user?(pending_request)

    responsible_person = pending_request.responsible_person
    if user&.account_security_completed?
      authenticate_user!
      responsible_person.add_user(user)
      PendingResponsiblePersonUser.where(email_address: user.email).delete_all
      redirect_to responsible_person_notifications_path(responsible_person)
    else
      user ||= SubmitUser.new(email: pending_request.email_address).tap do |u|
        u.dont_send_confirmation_instructions!
        u.save(validate: false)
      end
      bypass_sign_in(user)
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

  def set_team_member
    @team_member = @responsible_person.pending_responsible_person_users.build(team_member_params)
  end

  def authorize_responsible_person
    authorize @responsible_person, :show?
  end

  def team_member_params
    params.fetch(:team_member, {}).permit(
      :email_address,
    )
  end

  def send_invite_email
    NotifyMailer.send_responsible_person_invite_email(
      @responsible_person,
      @team_member,
      current_user.name,
    ).deliver_later
  end

  def signed_as_another_user?(invitation)
    current_user && current_user.email != invitation.email_address
  end

  # See: SecondaryAuthenticationConcern
  def current_operation
    SecondaryAuthentication::INVITE_USER
  end
end
