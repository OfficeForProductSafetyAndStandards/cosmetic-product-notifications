module Registration
  class NewAccountForm < Form
    attribute :full_name
    attribute :legacy_role_migrated, :boolean, default: false
    attribute :legacy_type_migrated, :boolean, default: false

    validates_presence_of :full_name
    validates :full_name, length: { maximum: User::NAME_MAX_LENGTH }, user_name_format: { message: :invalid }

    include EmailFormValidation

    def save
      return false unless valid?

      corrected_email = LegacyData.remove_plus_part(email)

      if (user = SubmitUser.where(email: email).or(SubmitUser.where(new_email: email)).first)
        send_link(user)
        true
      else
        user = SubmitUser.new(
          name: full_name,
          email: email,
          corrected_email: corrected_email,
          legacy_type: "submit_user",
          legacy_role_migrated: true,
          legacy_type_migrated: true,
        )

        if user.save(validate: false)
          user.add_role(:submit_user)
          user
        else
          false
        end
      end
    end

  private

    def send_link(user)
      if user.confirmed?
        SubmitNotifyMailer.send_account_already_exists(user).deliver_later
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

module LegacyData
  def self.remove_plus_part(email)
    return email unless email

    local, domain = email.split("@", 2)
    return email unless domain

    local = local.split("+").first
    [local, domain].join("@")
  end
end

## Roles TODO: This is where we can save the new role, and add the user to the submit_user role
## Upon transition to OneLogin this can go.
