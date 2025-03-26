class AntiVirusAnalyzer < ActiveStorage::Analyzer
  def self.accept?(_blob)
    true
  end

  def metadata
    download_blob_to_tempfile do |file|
      file_obj = nil
      begin
        antivirus_url = ENV["ANTIVIRUS_URL"] ? "#{ENV['ANTIVIRUS_URL'].chomp('/')}/v2/scan-chunked" : "http://localhost:3000/v2/scan-chunked"

        file_obj = File.new(file.path, "rb")
        file_content = file_obj.read

        response = RestClient::Request.execute(
          method: :post,
          url: antivirus_url,
          user: ENV["ANTIVIRUS_USERNAME"],
          password: ENV["ANTIVIRUS_PASSWORD"],
          headers: {
            "Content-Type" => "application/octet-stream",
            "Transfer-Encoding" => "chunked",
          },
          payload: file_content,
        )

        if response.code == 200
          result = JSON.parse(response.body)
          if result["malware"]
            { safe: false, message: result["reason"] }
          else
            { safe: true }
          end
        else
          { safe: false, message: response.body }
        end
      rescue StandardError => e
        Rails.logger.error("AntiVirus scan error: #{e.class} - #{e.message}")
        { safe: false, error: e.message }
      ensure
        file_obj&.close if file_obj && !file_obj.closed?
      end
    end
  end
end
