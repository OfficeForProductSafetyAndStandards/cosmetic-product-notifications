module Clamby
  # TODO: fix this properly by submitting a PR to Clamby
  def self.system_command(path)
    command = [].tap do |cmd|
      cmd << 'clamdscan'
      cmd << '--config-file=clamav/clamd.conf' if Rails.env.production?
      cmd << path
      cmd << '--no-summary'
    end
    command
  end
end

class AntiVirusAnalyzer < ActiveStorage::Analyzer
  def initialize(blob)
    Clamby.configure(daemonize: false)
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
