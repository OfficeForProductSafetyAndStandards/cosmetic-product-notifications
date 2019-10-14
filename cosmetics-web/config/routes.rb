require 'constraints/domain_constraint'
require 'constraints/domain_check'
require 'sidekiq/web'
require 'sidekiq/cron/web'

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USERNAME"]) &&
      ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
  end
end

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount GovukDesignSystem::Engine => '/', as: 'govuk_design_system_engine'

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

  constraints DomainConstraint.new(ENV.fetch("SEARCH_HOST") || ENV.fetch("COSMETICS_HOST")) do
    root "landing_page#index"

    scope module: "poison_centres", as: "poison_centre" do
      resources :notifications, param: :reference_number, only: %i[index show]
    end
  end

  constraints DomainConstraint.new(ENV.fetch("SUBMIT_HOST") || ENV.fetch("COSMETICS_HOST")) do
    root "landing_page#index"

    resources :responsible_persons, only: %i[show] do
      collection do
        resources :account, controller: "responsible_persons/account_wizard", only: %i[show update]
      end

      resources :contact_persons, controller: "responsible_persons/contact_persons", only: %i[show new create edit update] do
        member do
          get :resend_email
        end
      end

      resources :team_members, controller: "responsible_persons/team_members", only: %i[index new create] do
        collection do
          get :join
        end
      end

      resources :add_notification, controller: "responsible_persons/add_notification_wizard", only: %i[show new update]

      resources :notification_files, controller: "responsible_persons/notification_files", only: %i[show new create destroy] do
        collection do
          delete :destroy_all
        end
      end

      resources :notifications, param: :reference_number, controller: "responsible_persons/notifications", only: %i[index show new edit] do
        resources :build, controller: :notification_build, only: %i[show update new]
        resources :additional_information, controller: :additional_information, only: %i[index]
        resources :product_image_upload, controller: :product_image_upload, only: %i[new create]

        resources :components do
          resources :build, controller: :component_build, only: %i[show update new]
          resources :trigger_question, controller: :trigger_questions, only: %i[show update new]
          resources :formulation, controller: "formulation_upload", only: %w[new create]
          resources :nanomaterials, param: :nano_element_id do
            resources :build, controller: :nanomaterial_build, only: %i[show update new]
          end
        end

        member do
          post :confirm
        end
      end

      resources :non_standard_nanomaterials, controller: "responsible_persons/non_standard_nanomaterials", only: %i[index new edit] do
        resources :build, controller: :non_standard_nanomaterial_build, only: %i[show update new]

        member do
          post :confirm
        end
      end
    end

    resources :contact_persons, only: %i[] do
      collection do
        resources :confirmation, path: "confirm", param: :key, only: %i[show] do
          collection do
            get :link_expired, path: "link-expired"
          end
        end
      end
    end
  end

  domains = "#{ENV['SUBMIT_HOST']}, #{ENV['SEARCH_HOST']}, #{ENV['COSMETICS_HOST']}"
  constraints DomainCheck.new(domains) do
    root 'errors#internal_server_error'
  end

  resource :declaration, controller: :declaration, only: %i[show] do
    post :accept
  end

  resource :dashboard, controller: :dashboard, only: %i[show]

  namespace :guidance, as: "" do
    get :how_to_notify_nanomaterials, path: "how-to-notify-nanomaterials"
    get :how_to_prepare_images_for_notification, path: "how-to-prepare-images-for-notification"
  end

  namespace :help, as: "" do
    get :terms_and_conditions, path: "terms-and-conditions"
    get :privacy_notice, path: "privacy-notice"
  end

  get "invalid-account", to: "errors#invalid_account", as: :invalid_account

  match "/404", to: "errors#not_found", via: :all
  match "/403", to: "errors#forbidden", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/503", to: "errors#timeout", via: :all
end
# rubocop:enable Metrics/BlockLength
