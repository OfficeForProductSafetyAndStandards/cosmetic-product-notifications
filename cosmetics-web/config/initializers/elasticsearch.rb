# Elasticsearch::Model.client = Elasticsearch::Client.new(Rails.application.config_for(:opensearch))
# # bypasses the recently introduced version check to allow ES gems to connect to an Opensearch 1 server
# Elasticsearch::Model.client.instance_variable_set("@verified", true)

require 'cgi'
require 'json'
require 'uri'

if Rails.env.production?
  if ENV['COPILOT_ENVIRONMENT_NAME'] # DBT Platform
    kwargs = { url: URI::parse(CGI.unescape(ENV.fetch('OPENSEARCH_URL'))) }
  elsif ENV['VCAP_SERVICES'] # Govt PaaS / Cloud Foundry Platform
    kwargs = { url: JSON.parse(ENV["VCAP_SERVICES"] && CF::App::Credentials.find_by_service_name("cosmetics-opensearch-1")["uri"]) }
  else
    raise Exception, 'Platform type not identified'
  end
else
  kwargs = { host: 'http://localhost:9200' }
end

Elasticsearch::Model.client = Elasticsearch::Client.new(kwargs)
# bypasses the recently introduced version check to allow ES gems to connect to an Opensearch 1 server
Elasticsearch::Model.client.instance_variable_set("@verified", true)
