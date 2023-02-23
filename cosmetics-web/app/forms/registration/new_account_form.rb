module Registration
  class NewAccountForm < Form
    attribute :full_name

    validates_presence_of :full_name
    validates :full_name, length: { maximum: User::NAME_MAX_LENGTH }, user_name_format: { message: :invalid }

    include EmailFormValidation

    def save
      return false unless valid?

      if (user = SubmitUser.where(email:).or(SubmitUser.where(new_email: email)).first)
        send_link(user)
        true
      else
        user = SubmitUser.new(name: full_name, email:)
        user.save(validate: false)
        user
      end
    end

  private

    def send_link(user)
      if user.confirmed?
        SubmitNotifyMailer.send_account_already_exists(user).deliver_later
      else
        user.resend_account_setup_link
      end
    end
  end
end
