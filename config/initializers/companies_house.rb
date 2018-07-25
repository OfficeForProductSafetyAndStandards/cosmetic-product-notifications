Rails.application.config.companies_house_constants = YAML.load_file(
  Rails.root.join("config", "companies_house_constants.yml")
)
