class InviteSearchUser
  include Interactor

  delegate :user, :role, :name, to: :context

  def call
    context.fail!(error: "No user name supplied") unless name
    context.fail!(error: "No email or user supplied") unless email || user
    context.fail!(error: "No user role supplied") unless role

    context.fail!(error: "Supplied email address is already in use by a non-search user") if email_taken_by_other_user_type?

    context.user ||= create_user

    send_invite
  end

private

  def email_taken_by_other_user_type?
    SubmitUser.where(email: email).or(SupportUser.where(email: email)).exists?
  end

  def create_user
    SearchUser.find_or_create_by!(email: email) do |new_user|
      new_user.name = name
      new_user.skip_password_validation = true
      new_user.invite = true
      new_user.add_role(role)
    end
  end

  def send_invite
    if user.account_security_completed?
      Rails.logger.info "[InviteSearchUser] User with id: #{user.id} is already registered in the service and cannot be re-invited."
    else
      if !user.invitation_token || (user.invited_at < 1.hour.ago)
        user.update! invitation_token: user.invitation_token || SecureRandom.hex(15), invited_at: Time.zone.now
      end

      SearchNotifyMailer.invitation_email(user).deliver_later
    end
  end

  def email
    context.email&.downcase
  end
end
