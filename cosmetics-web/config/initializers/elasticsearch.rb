require 'cgi'
require 'json'
require 'uri'

def opensearch_url
  if ENV['COPILOT_ENVIRONMENT_NAME'] # DBT Platform
    URI::parse(CGI.unescape(ENV.fetch('OPENSEARCH_URL')))
  else
    # Fallback to the original logic
    ENV["VCAP_SERVICES"] && CF::App::Credentials.find_by_service_name("cosmetics-opensearch-1")["uri"]
  end
end

def get_opensearch_config
  if Rails.env.production?
    { url: opensearch_url, transport_options: { request: { timeout: 5 } } }
  else
    { host: 'http://localhost:9200' }
  end
end

Elasticsearch::Model.client = Elasticsearch::Client.new(get_opensearch_config)
# bypasses the recently introduced version check to allow ES gems to connect to an Opensearch 1 server
Elasticsearch::Model.client.instance_variable_set("@verified", true)
