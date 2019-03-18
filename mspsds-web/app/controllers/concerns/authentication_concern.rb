module AuthenticationConcern
  extend ActiveSupport::Concern
  include Shared::Web::Concerns::AuthenticationConcern
  def no_need_to_authenticate
    return true if request.original_fullpath.include? "terms_and_conditions"
    return true if request.original_fullpath.include? "about"

    false
  end
end
