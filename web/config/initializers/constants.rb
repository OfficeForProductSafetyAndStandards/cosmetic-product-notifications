Rails.application.config.legislation_constants = YAML.load_file(
  Rails.root.join("config", "legislation_constants.yml")
)
