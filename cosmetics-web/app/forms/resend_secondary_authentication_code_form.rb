class ResendSecondaryAuthenticationCodeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :mobile_number
  attribute :user

  validates_presence_of :mobile_number,
                        message: I18n.t(:blank, scope: %i[resend_secondary_authentication_code_form mobile_number]),
                        if: -> { user.mobile_number_change_allowed? }
  validates :mobile_number,
            phone: { message: :invalid, allow_international: -> { user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER } },
            if: -> { user.mobile_number_change_allowed? && mobile_number.present? }
end
