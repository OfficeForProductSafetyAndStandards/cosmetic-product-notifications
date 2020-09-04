module Registration
  class NewAccountForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include EmailFormValidation

    attribute :full_name

    private_class_method def self.error_message(attr, key)
      I18n.t(key, scope: "new_account.#{attr}")
    end

    validates_presence_of :full_name, message: error_message(:full_name, :blank)

    def save
      return false unless self.valid?
      user = SubmitUser.new(name: full_name, email: email)
      user.save(validate: false)
#      NotifyMailer.send_account_confirmation_email(user).deliver_later
      user
    end

    def [](field)
      public_send(field.to_sym)
    end
  end
end
