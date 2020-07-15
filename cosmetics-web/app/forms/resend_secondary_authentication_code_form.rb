class ResendSecondaryAuthenticationCodeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :mobile_number
  attribute :user

  validates_presence_of :mobile_number,
                        message: I18n.t(:blank, scope: %i[activerecord errors models user attributes mobile_number]),
                        if: -> { user.mobile_number_change_allowed? }
  validates :mobile_number,
            phone: { message: I18n.t(:invalid, scope: %i[activerecord errors models user attributes mobile_number]) },
            if: -> { user.mobile_number_change_allowed? && mobile_number.present? }
end
