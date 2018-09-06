source "https://rubygems.org"

ruby File.read(".ruby-version").strip

# Will Paginate must be installed before elasticsearch
# https://github.com/elastic/elasticsearch-rails/issues/239
gem "will_paginate"

gem "ar_merge"
gem "aws-sdk-s3"
gem "axlsx", git: "https://github.com/randym/axlsx.git", ref: "c8ac844"
gem "axlsx_rails"
gem "bootsnap", ">= 1.1.0"
gem "cf-app-utils"
gem "clamby"
gem "companies-house-rest"
gem "devise"
gem "devise_invitable"
gem "elasticsearch-model"
gem "elasticsearch-rails"
gem "faraday_middleware-aws-sigv4"
gem "jbuilder", "~> 2.5"
gem "mini_magick"
gem "notifications-ruby-client"
gem "paper_trail"
gem "pg", "~> 0.18"
gem "puma", "~> 3.0"
gem "pundit"
gem "rails", "~> 5.2"
gem "rolify"
gem "rubyzip", ">= 1.2.1"
gem "sass-rails", "~> 5.0"
gem "sidekiq"
gem "slim-rails"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "wicked_pdf"
gem "wkhtmltopdf-binary"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "brakeman"
  gem "byebug", platform: :mri
  gem "debase"
  gem "govuk-lint"
  gem "rubocop"
  gem "ruby-debug-ide"
  gem "slim_lint"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", "~> 3.0.5"
  gem "solargraph"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
