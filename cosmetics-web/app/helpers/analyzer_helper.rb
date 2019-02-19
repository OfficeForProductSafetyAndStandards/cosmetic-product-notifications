module AnalyzerHelper
  include Shared::Web::CountriesHelper

  def get_notification_file_from_blob(blob)
    ::NotificationFile.find_by(id: blob.attachments.first.record_id)
  end

  def get_gov_uk_country_code(cpnp_country_code)
    return if cpnp_country_code.length < 2
    country = all_countries.find { |c| c[1].include? cpnp_country_code }
    country && country[1]
  end
end
