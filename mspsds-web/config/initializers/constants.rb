Rails.application.config.legislation_constants = YAML.load_file(
  Rails.root.join("config", "legislation_constants.yml")
)
Rails.application.config.hazard_constants = YAML.load_file(
  Rails.root.join("config", "hazard_constants.yml")
)
Rails.application.config.product_constants = YAML.load_file(
  Rails.root.join("config", "product_constants.yml")
)
Rails.application.config.team_names = YAML.load_file(
  Rails.root.join("config", "important_team_names.yml")
)
