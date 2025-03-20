require 'cgi'
require 'uri'

module CredentialsResolver
  module_function

  def pgsql_uri
    if ENV["DATABASE_CREDENTIALS"].present?
      parse_database_config(ENV["DATABASE_CREDENTIALS"])
    else
      # Fallback to the original logic
      JSON.parse(ENV["VCAP_SERVICES"])["postgres"][0]["credentials"]["uri"]
    end
  end

  def parse_database_config(config_json)
    config = JSON.parse(config_json)

    # Construct the database URI
    "#{config["engine"]}://#{config["username"]}:#{config["password"]}@#{config["host"]}:#{config["port"]}/#{config["dbname"]}"
  end

  def opensearch_url
    if ENV["OPENSEARCH_URL"].present?
      URI::parse(CGI.unescape(ENV.fetch('OPENSEARCH_URL')))
    else
      # Fallback to the original logic
      ENV["VCAP_SERVICES"] && CF::App::Credentials.find_by_service_name("cosmetics-opensearch-1")["uri"]
    end
  end
end
