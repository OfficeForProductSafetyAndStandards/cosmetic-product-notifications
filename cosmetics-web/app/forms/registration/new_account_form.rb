module Registration
  class NewAccountForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :full_name

    private_class_method def self.error_message(attr, key)
      I18n.t(key, scope: "new_account.#{attr}")
    end

    validates_presence_of :full_name, message: error_message(:full_name, :blank)
    include EmailFormValidation

    def save
      return false unless self.valid?
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
      if (user = SubmitUser.find_by(email: email))
        if user.confirmed?
          NotifyMailer.send_account_already_exists(user).deliver_later
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
