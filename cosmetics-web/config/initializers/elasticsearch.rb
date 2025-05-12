# Configure the client with settings and middleware
client_config = Rails.application.config_for(:opensearch)

# Custom middleware to handle circuit breaker exceptions
module Elasticsearch
  module Transport
    module Transport
      module Middleware
        class CircuitBreakerMiddleware
          def initialize(app)
            @app = app
          end

          def call(env)
            @app.call(env)
          rescue Elastic::Transport::Transport::Errors::TooManyRequests => e
            # Log circuit breaker errors but allow the app to continue
            Rails.logger.error "[Opensearch] Circuit breaker error: #{e.message}"
            # Re-raise so the error can be caught elsewhere
            raise e
          end
        end
      end
    end
  end
end

# Add custom middleware to the client, but after Rails is fully initialized
# to avoid FrozenError with ActionText
Rails.application.config.after_initialize do
  # Setup custom middleware
  client_config[:transport_options] ||= {}
  client_config[:transport_options][:middleware] ||= []
  client_config[:transport_options][:middleware] << lambda { |f|
    Elasticsearch::Transport::Transport::Middleware::CircuitBreakerMiddleware.new(f)
  }
end

Elasticsearch::Model.client = Elasticsearch::Client.new(client_config)

# bypasses the recently introduced version check to allow ES gems to connect to an Opensearch 1 server
Elasticsearch::Model.client.instance_variable_set("@verified", true)
