class InviteSearchUser
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
    SearchUser.find_or_create_by!(email:) do |user|
      user.name = name
      user.skip_password_validation = true
      user.role = role
      user.invite = true
    end
  end

  def send_invite
    if user.account_security_completed?
      Rails.logger.info "[InviteSearchUser] User with id: #{user.id} is already registered in the service and cannot be re-invited."
    else
      if !user.invitation_token || (user.invited_at < 1.hour.ago)
        user.update! invitation_token: (user.invitation_token || SecureRandom.hex(15)), invited_at: Time.zone.now
      end

      SearchNotifyMailer.invitation_email(user).deliver_later
    end
  end

  def email
    # User emails are forced to lower case when saved, so we must compare case insensitively
    context.email&.downcase
  end
end
