Rails.application.config.companies_house_constants = YAML.load_file(
  Rails.root.join("config", "companies_house_constants.yml")
)
Rails.application.config.view_company_url = "https://beta.companieshouse.gov.uk/company/"
