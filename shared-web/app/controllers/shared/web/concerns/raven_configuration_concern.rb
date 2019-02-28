module Shared
  module Web
    module Concerns
      module RavenConfigurationConcern
        extend ActiveSupport::Concern

        def set_raven_context
          Raven.user_context(id: User.current&.id)
          Raven.extra_context(params: params.to_unsafe_h, url: request.url)
        end
      end
    end
  end
end
