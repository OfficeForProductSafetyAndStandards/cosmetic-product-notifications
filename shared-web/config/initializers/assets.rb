# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "assets", "images")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "govuk-frontend", "assets", "fonts")
Rails.application.config.assets.paths << Rails.root.join("node_modules", "html5shiv", "dist")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
  application-ie8.css
  html5shiv.js
  favicon.ico
  govuk-mask-icon.svg
  govuk-apple-touch-icon-180x180.png
  govuk-apple-touch-icon-167x167.png
  govuk-apple-touch-icon-152x152.png
  govuk-apple-touch-icon.png
  govuk-opengraph-image.png
  govuk-logotype-crown.png
  govuk-crest-2x.png
]

Rails.application.config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store, size: 128.megabytes) unless Rails.env.production?
end
