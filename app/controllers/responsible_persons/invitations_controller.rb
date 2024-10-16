class ResponsiblePersons::InvitationsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :authorize_responsible_person
  before_action :validate_responsible_person
  before_action :set_invitation, only: %i[cancel destroy resend]

  skip_before_action :create_or_join_responsible_person, only: :create

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

  def cancel; end

  def destroy
    case params[:cancel_invitation]
    when "yes"
      @invitation.destroy!
      redirect_to(responsible_person_team_members_path(@responsible_person), confirmation: "The invitation was cancelled")
    when "no"
      redirect_to(responsible_person_team_members_path(@responsible_person))
    else
      @invitation.errors.add(:cancel_invitation, "Select yes if you want to cancel the invitation")
      render :cancel
    end
  end

  def resend
    ActiveRecord::Base.transaction do
      @invitation.refresh_token_expiration!
      @invitation.update!(inviting_user: current_user)
      send_invite_email
    end

    redirect_to responsible_person_team_members_path(@responsible_person), confirmation: "Invite sent to #{@invitation.email_address}"
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def set_invitation
    @invitation = @responsible_person.pending_responsible_person_users.find(params[:id])
  end

  def authorize_responsible_person
    authorize @responsible_person, :update?
  end

  def create_invitation!
    # If an existing user is invited, the name of the existing user will be used instead of the one provided in the form.
    name = SubmitUser.find_by(email: @invite_member_form.email)&.name || @invite_member_form.name
    @invitation = @responsible_person.pending_responsible_person_users.create!(
      name:,
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

  def invite_member_form_params
    params.require(:invite_member_form).permit(:name, :email)
  end

  # See: SecondaryAuthenticationConcern
  def current_operation
    SecondaryAuthentication::Operations::INVITE_USER
  end
end
