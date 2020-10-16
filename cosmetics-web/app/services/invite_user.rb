class InviteUser
  include Interactor

  delegate :user, :role, :name, to: :context

  def call
    context.fail!(error: "No user name supplied") unless name
    context.fail!(error: "No email or user supplied") unless email || user
    context.fail!(error: "No user role supplied") unless role

    context.user ||= create_user

    send_invite
  end

private

  def create_user
    user = SearchUser.create!(
      name: name,
      email: email,
      skip_password_validation: true,
      role: role,
      invite: true,
    )
    user
  end

  def send_invite
    if !user.invitation_token || (user.invited_at < 1.hour.ago)
      user.update! invitation_token: (user.invitation_token || SecureRandom.hex(15)), invited_at: Time.current
    end

    SearchNotifyMailer.invitation_email(user).deliver_later
  end

  def email
    # User emails are forced to lower case when saved, so we must compare case insensitively
    context.email&.downcase
  end
end
