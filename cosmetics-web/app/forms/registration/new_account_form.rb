module Registration
  class NewAccountForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :full_name

    validates_presence_of :full_name
    include EmailFormValidation

    def save
      return false unless valid?
      return true if user_exists?

      user = SubmitUser.new(name: full_name, email: email)
      user.save(validate: false)
      user
    end

    def [](field)
      public_send(field.to_sym)
    end

  private

    def user_exists?
      if (user = SubmitUser.where("lower(email) = ?", email&.downcase).first)
        if user.confirmed?
          SubmitNotifyMailer.send_account_already_exists(user).deliver_later
        else
          user.resend_confirmation_instructions
        end
        true
      else
        false
      end
    end
  end
end
