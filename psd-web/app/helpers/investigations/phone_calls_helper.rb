module Investigations::PhoneCallsHelper
  def get_call_with_field correspondence
    output = ""
    output += correspondence.correspondent_name if correspondence.correspondent_name.present?
    output += " (" if [correspondence.correspondent_name, correspondence.phone_number].all?(&:present?)
    output += correspondence.phone_number if correspondence.phone_number.present?
    output += ")" if [correspondence.correspondent_name, correspondence.phone_number].all?(&:present?)
    output
  end
end
