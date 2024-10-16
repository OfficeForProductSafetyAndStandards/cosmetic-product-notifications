require "sinatra/base"
require "redis"
require "pry"
require "cf-app-utils"

class App < Sinatra::Base
  if ENV["HTTP_AUTH_USER"] && ENV["HTTP_AUTH_PASS"]
    use Rack::Auth::Basic, "Protected Area" do |username, password|
      username == ENV["HTTP_AUTH_USER"] && password == ENV["HTTP_AUTH_PASS"]
    end
  end

  get "/text" do
    redis.get("text")
  end

  post "/save" do
    redis.set("text", params["message"])
    redis.expire("text", 15 * 60 * 3) # 3 is for debug
  end

private

  def redis
    @redis ||= if ENV["VCAP_SERVICES"]
                 uri = CF::App::Credentials.find_by_service_name("opss-smoke-test-text-relay-redis")["uri"]
                 Redis.new(url: uri)
               else
                 Redis.new(host:, port:, db: 15)
               end
  end

  def host
    ENV["VCAP_SERVICES"] && CF::App::Credentials.find_by_service_name("opss-smoke-test-text-relay-redis")["host"] || ENV.fetch("REDIS_HOST", "localhost")
  end

  def port
    ENV["VCAP_SERVICES"] && CF::App::Credentials.find_by_service_name("opss-smoke-test-text-relay-redis")["port"] || ENV.fetch("REDIS_PORT", "6379")
  end
end
