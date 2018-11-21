class AntiVirusAnalyzer < ActiveStorage::Analyzer
  def initialize(blob)
    config = { daemonize: true }
    config[:config_file] = "clamav/clamd.conf" if Rails.env.production?
    Clamby.configure(config)
    super(blob)
  end

  def self.accept?(_blob)
    true
  end

  def metadata
    download_blob_to_tempfile do |file|
      is_safe = Clamby.safe? file.path
      purge_blob unless is_safe
      { safe: is_safe }
    end
  end

private

  def purge_blob
    attachment = ActiveStorage::Attachment.find_by blob_id: @blob.id
    attachment.purge
  end
end
