EU_EXIT_DATE = Time.zone.parse("2021-01-01T00:00")
SUBMISSION_WINDOW_END_DATE = Time.zone.parse("2021-03-31T23:00")
Rails.application.config.domains_allowing_otp_whitelisting =
  YAML.load_file(Rails.root.join("config/constants/domains_allowing_otp_whitelisting.yml"))
