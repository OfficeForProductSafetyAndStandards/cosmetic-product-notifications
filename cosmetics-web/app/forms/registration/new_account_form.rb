module Registration
  class NewAccountForm < Form
    attribute :full_name

    validates_presence_of :full_name
    include EmailFormValidation

    def save
      return false unless valid?

      if (user = SubmitUser.where(email: email).or(SubmitUser.where(new_email: email)).first)
        send_link(user)
        true
      else
        user = SubmitUser.new(name: full_name, email: email)
        user.save(validate: false)
        user
      end
    end

  private

    def send_link(user)
      if user.confirmed?
        SubmitNotifyMailer.send_account_already_exists(user).deliver_later
      # TODO: Remove this branch based on pending invitations once invitations
      # contain user name (pending feature).
      # Once that happens logic can default to resending the account setup link
      # as done with user who registered without an invitation.
      elsif (invitation = PendingResponsiblePersonUser.where(email_address: user.email).last)
        invitation.refresh_token_expiration!
        SubmitNotifyMailer.send_responsible_person_invite_email(
          invitation.responsible_person, invitation, invitation.inviting_user.name
        ).deliver_later
      else
        user.resend_confirmation_instructions
      end
    end
  end
end
