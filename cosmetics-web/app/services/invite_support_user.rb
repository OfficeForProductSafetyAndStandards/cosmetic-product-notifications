class InviteSupportUser
  include Interactor

  delegate :user, :name, to: :context

  def call
    context.fail!(error: "No user name supplied") unless name
    context.fail!(error: "No email or user supplied") unless email || user

    context.fail!(error: "Supplied email address is already in use by a non-support user") if email_taken_by_other_user_type?

    context.user ||= create_user

    send_invite
  end

private

  def email_taken_by_other_user_type?
    SubmitUser.where(email:).or(SearchUser.where(email:)).count.positive?
  end

  def create_user
    SupportUser.find_or_create_by!(email: email) do |user|
      user.name = name
      user.skip_password_validation = true
      user.invite = true
      user.save!
      user.add_role(:opss_general)
    end
  end

  def send_invite
    if user.account_security_completed?
      Rails.logger.info "[InviteSupportUser] User with id: #{user.id} is already registered in the service and cannot be re-invited."
    else
      if !user.invitation_token || (user.invited_at < 1.hour.ago)
        user.update! invitation_token: user.invitation_token || SecureRandom.hex(15), invited_at: Time.zone.now
      end

      user.update! deactivated_at: nil

      SupportNotifyMailer.invitation_email(user).deliver_later
    end
  end

  def email
    # User emails are forced to lower case when saved, so we must compare case insensitively
    context.email&.downcase
  end
end
