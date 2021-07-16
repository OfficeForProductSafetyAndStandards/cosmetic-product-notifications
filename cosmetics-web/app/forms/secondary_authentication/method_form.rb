module SecondaryAuthentication
  class MethodForm < Form
    MOBILE_NUMBER_VISIBLE_CHARS = 4

    attribute :authentication_method
    attribute :mobile_number

    validates_presence_of :authentication_method

    def partially_hidden_mobile_number
      return if mobile_number.blank?

      hidden_chars = mobile_number.size - MOBILE_NUMBER_VISIBLE_CHARS
      "*" * hidden_chars + mobile_number.last(MOBILE_NUMBER_VISIBLE_CHARS)
    end
  end
end
