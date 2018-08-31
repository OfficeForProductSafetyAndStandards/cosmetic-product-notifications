# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "assets")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "assets", "images")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "assets", "fonts")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
  govuk-frontend/assets/images/favicon.ico
  govuk-frontend/assets/images/govuk-mask-icon.svg
  govuk-frontend/assets/images/govuk-apple-touch-icon-180x180.png
  govuk-frontend/assets/images/govuk-apple-touch-icon-167x167.png
  govuk-frontend/assets/images/govuk-apple-touch-icon-152x152.png
  govuk-frontend/assets/images/govuk-apple-touch-icon.png
  govuk-frontend/assets/images/govuk-opengraph-image.png
  govuk-frontend/assets/images/govuk-logotype-crown.png
]
