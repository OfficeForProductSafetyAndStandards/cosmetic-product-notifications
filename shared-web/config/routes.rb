require 'sidekiq/web'
require 'sidekiq/cron/web'

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USERNAME"]) &&
      ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
  end
end

Shared::Web::Engine.routes.draw do
  resource :session, only: %i[new] do
    member do
      get :new
      get :signin
      get :logout
    end
  end

  unless Rails.env.production? && (!ENV["SIDEKIQ_USERNAME"] || !ENV["SIDEKIQ_PASSWORD"])
    mount Sidekiq::Web => "/sidekiq"
  end

  if Rails.env.development?
    get "components/:component" => "components_gallery#show"
  end
end
