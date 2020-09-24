class ResponsiblePersons::TeamMembersController < ApplicationController
  before_action :set_responsible_person
  before_action :set_team_member, only: %i[new create]
  skip_before_action :create_or_join_responsible_person

  def new; end

  def create
    @responsible_person.save
    if @responsible_person.errors.empty?
      send_invite_email
      redirect_to responsible_person_team_members_path(@responsible_person)
    else
      render :new
    end
  end

  def join
    return render "signed_as_another_user" if current_submit_user

    pending_request = PendingResponsiblePersonUser.find_by!(invitation_token: params[:invitation_token])
    responsible_person = pending_request.responsible_person
    if (user = SubmitUser.find_by(email: pending_request.email)
        responsible_person.add_user(current_user)
        # redirect?
    else
      user = SubmitUser.new(email: email)
      user.save(validate: false)
      responsible_person.add_user(current_user)
      sign_in(user)

      redirect_to registration_new_account_security_path
    end

  end

  def sign_out_before_confirming_email
    sign_out
    redirect_to registration_confirm_submit_user_path(confirmation_token: params[:confirmation_token])
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def team_member_params
    params.fetch(:team_member, {}).permit(
      :email_address,
    )
  end

  def set_team_member
    @team_member = @responsible_person.pending_responsible_person_users.build(team_member_params)
  end

  def send_invite_email
    NotifyMailer.send_responsible_person_invite_email(@responsible_person.id, @responsible_person.name,
                                                      @team_member.email_address, current_user.name).deliver_later
  end
end
