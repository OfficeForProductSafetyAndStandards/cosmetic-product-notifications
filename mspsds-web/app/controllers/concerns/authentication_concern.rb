module AuthenticationConcern
  extend ActiveSupport::Concern
  include Shared::Web::Concerns::AuthenticationConcern
  def no_need_to_authenticate
    request.original_fullpath.include? "terms_and_conditions"
  end
end
