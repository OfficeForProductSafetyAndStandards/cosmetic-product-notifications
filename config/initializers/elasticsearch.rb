require "faraday_middleware/aws_sigv4"

def aws_elasticsearch_client
  Elasticsearch::Client.new(url: ENV["AWS_ELASTICSEARCH_URL"]) do |f|
    f.request :aws_sigv4,
              service: "es",
              region: ENV["AWS_REGION"],
              access_key_id: ENV["AWS_ACCESS_KEY_ID"],
              secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    f.response :logger
    f.adapter  Faraday.default_adapter
  end
end

def local_elasticsearch_client
  config = {
    host: "elasticsearch",
    transport_options: {
      request: { timeout: 5 }
    }
  }

  Elasticsearch::Client.new(config)
end

Elasticsearch::Model.client = if Rails.env.production?
                                aws_elasticsearch_client
                              else
                                local_elasticsearch_client
                              end
