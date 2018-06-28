require "faraday_middleware/aws_signers_v4"

config = {
  host: "http://localhost:9200/",
  transport_options: {
    request: { timeout: 5 }
  }
}

if File.exist?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end
# Elasticsearch::Model.client = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = Elasticsearch::Client.new(url: "http://es.eu-west-2.amazonaws.com") do |f|
  f.request :aws_signers_v4,
            credentials: Aws::Credentials.new("AWS_KEY", "AWS_SECRET"),
            service_name: "es",
            region: "eu-west-2"

  f.response :logger
  f.adapter  Faraday.default_adapter
end
