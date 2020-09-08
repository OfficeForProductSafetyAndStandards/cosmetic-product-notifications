module Registration
  class SecurityDetailsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :mobile_number
    attribute :password
    attribute :user

    validates :password, length: { minimum: 8 }
    validates :mobile_number, presence: true, format: { with: /\A[0-9 -]+\z/ }, length: { minimum: 11 }

    private_class_method def self.error_message(attr, key)
      I18n.t(key, scope: "security_details.#{attr}")
    end

    def update!
      valid? && user.update!(mobile_number: mobile_number, password: password)
    end

    def [](field)
      public_send(field.to_sym)
    end
  end
end
