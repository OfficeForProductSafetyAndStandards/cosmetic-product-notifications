module SupportPortal
  module SentryConfigurationConcern
    extend ActiveSupport::Concern

    def set_sentry_context
      Sentry.set_user(id: current_user.id) if current_user
      Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
    end
  end
end
