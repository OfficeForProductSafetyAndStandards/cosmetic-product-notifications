# Taken from https://github.com/rails/webpacker/issues/1752 to remove dependency on rack-proxy, which clashes with some of our other dependencies
class Webpacker::DevServerProxy
  def initialize(app = nil, _opts = {})
    @app = app
  end

  def call(env)
    if env["PATH_INFO"].start_with?("/#{public_output_uri_path}") && Webpacker.dev_server.running?
      scheme = "http#{Webpacker.dev_server.https? ? 's' : ''}"
      uri = "#{scheme}://#{Webpacker.dev_server.host_with_port}#{env['PATH_INFO']}"
      request = Net::HTTP::Get.new(uri)
      response = Net::HTTP.start(Webpacker.dev_server.host, Webpacker.dev_server.port) do |http|
        http.request(request)
      end
      headers = {}
      response.each_header do |k, v|
        headers[k] = v unless k == "transfer-encoding" || (k == "content-length" && Webpacker.dev_server.https?)
      end
      [response.code.to_i, headers, [response.read_body]]
    else
      @app.call(env)
    end
  end

private

  def public_output_uri_path
    Webpacker.config.public_output_path.relative_path_from(Webpacker.config.public_path)
  end
end
