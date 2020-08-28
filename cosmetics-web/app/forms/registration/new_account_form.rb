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

    def [](field)
      public_send(field.to_sym)
    end
  end
end
