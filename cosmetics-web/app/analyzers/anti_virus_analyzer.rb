class AntiVirusAnalyzer < ActiveStorage::Analyzer
  include AnalyzerHelper

  def self.accept?(_blob)
    true
  end

  def metadata
    notification_file = get_notification_file_from_blob(@blob)
    metadata = download_blob_to_tempfile do |file|
      response = RestClient::Request.execute method: :post, url: ENV["ANTIVIRUS_URL"], user: ENV["ANTIVIRUS_USERNAME"], password: ENV["ANTIVIRUS_PASSWORD"], payload: { file: file }
      body = JSON.parse(response.body)
      { safe: body["safe"] }
    end

    if metadata["safe"] == false && notification_file.present?
      notification_file.update(upload_error: :file_flagged_as_virus)
    end

    metadata
  end
end
