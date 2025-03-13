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
end
