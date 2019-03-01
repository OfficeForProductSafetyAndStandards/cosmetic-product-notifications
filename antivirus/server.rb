require "clamby"
require "sinatra"

Clamby.configure({
  daemonize: true,
  error_clamscan_missing: true,
  error_clamscan_client_error: true,
  error_file_missing: true,
  error_file_virus: false
})

set :bind, "0.0.0.0"

use Rack::Auth::Basic, "Unauthorized" do |username, password|
  Rack::Utils.secure_compare(username, ENV["ANTIVIRUS_USERNAME"]) && Rack::Utils.secure_compare(password, ENV["ANTIVIRUS_PASSWORD"])
end if ENV["ANTIVIRUS_USERNAME"]

post "/safe" do
  content_type :json

  file_path = params["file"][:tempfile].path
  File.chmod(0777, file_path)
  { safe: Clamby.safe?(file_path) }.to_json
end
