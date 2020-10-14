EU_EXIT_DATE = Time.zone.parse("2020-01-31T23:00")
SUBMISSION_WINDOW_END_DATE = EU_EXIT_DATE + 90.days
Rails.application.config.domains_allowing_otp_whitelisting =
  YAML.load_file(Rails.root.join("config/constants/domains_allowing_otp_whitelisting.yml"))
