module HttpAuthConcern
  extend ActiveSupport::Concern

  included do
    if ENV["ACCESSIBILITY_BASIC_AUTH_USERNAME"].present? && ENV["ACCESSIBILITY_BASIC_AUTH_PASSWORD"].present?
      http_basic_authenticate_with(
        name: ENV.fetch("ACCESSIBILITY_BASIC_AUTH_USERNAME"),
        password: ENV.fetch("ACCESSIBILITY_BASIC_AUTH_PASSWORD"),
      )
    end
  end
end
