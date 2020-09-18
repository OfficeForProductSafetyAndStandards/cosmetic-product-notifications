require "constraints/domain_inclusion_constraint"
require "constraints/domain_exclusion_constraint"
require "sidekiq/web"
require "sidekiq/cron/web"

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USERNAME"]) &&
      ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
  end
end

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount GovukDesignSystem::Engine => "/", as: "govuk_design_system_engine"

  get "/sign_up", to: redirect("/")
  resource :password_changed, controller: "users/password_changed", only: :show, path: "password-changed"

  get "two-factor", to: "secondary_authentications#new", as: :new_secondary_authentication
  post "two-factor", to: "secondary_authentications#create", as: :secondary_authentication

  get "text-not-received", to: "secondary_authentications/resend_code#new", as: :new_resend_secondary_authentication_code
  post "text-not-received", to: "secondary_authentications/resend_code#create", as: :resend_secondary_authentication_code

  unless Rails.env.production? && (!ENV["SIDEKIQ_USERNAME"] || !ENV["SIDEKIQ_PASSWORD"])
    mount Sidekiq::Web => "/sidekiq"
  end

  constraints DomainInclusionConstraint.new(ENV.fetch("SEARCH_HOST")) do
    devise_for :search_users,
               path: "",
               path_names: { sign_up: "sign-up", sign_in: "sign-in", sign_out: "sign-out" },
               controllers: { passwords: "users/passwords", registrations: "users/registrations", sessions: "users/sessions", unlocks: "users/unlocks" }
    devise_scope :search_user do
      resource :check_your_email, path: "check-your-email", only: :show, controller: "users/check_your_email"
      post "sign-out-before-resetting-password", to: "users/passwords#sign_out_before_resetting_password"
      post "sign-out-before-confirming-email", to: "users/confirmations#sign_out_before_confirming_email"
    end
    root "landing_page#index"

    scope module: "poison_centres", as: "poison_centre" do
      resources :notifications, param: :reference_number, only: %i[index show]
    end
    resources :users, only: [:update] do
      member do
        get "complete-registration", action: :complete_registration
        post "sign-out-before-accepting-invitation", action: :sign_out_before_accepting_invitation
      end
    end
  end

  # All requests besides "Search" host ones will default to "Submit" pages.
  constraints DomainExclusionConstraint.new(ENV.fetch("SEARCH_HOST")) do
    devise_for :submit_users,
               path: "",
               path_names: { sign_in: "sign-in", sign_out: "sign-out" },
               controllers: { confirmations: "users/confirmations", passwords: "users/passwords", sessions: "users/sessions", unlocks: "users/unlocks" },
               skip: %i[confirmation registration]
    devise_scope :submit_user do
      resource :check_your_email, path: "check-your-email", only: :show, controller: "users/check_your_email"
      post "sign-out-before-resetting-password", to: "users/passwords#sign_out_before_resetting_password"
    end

    get "create-an-account", to: "registration/new_accounts#new", as: :registration_new_submit_user
    post "create-an-account", to: "registration/new_accounts#create", as: :registration_create_submit_user
    get "confirm-new-account", to: "registration/new_accounts#confirm", as: :registration_confirm_submit_user
    get "account-security", to: "registration/account_security#new", as: :registration_new_account_security
    post "account-security", to: "registration/account_security#create", as: :registration_create_account_security
    post "sign-out-before-confirming-email", to: "registration/new_accounts#sign_out_before_confirming_email"

    root "landing_page#index"


    resources :responsible_persons, only: %i[show] do
      collection do
        resources :account, controller: "responsible_persons/account_wizard", only: %i[show update]
      end

      resources :nanomaterials, controller: :nanomaterial_notifications, only: %i[index new create], shallow: true do
        member do
          get :name
          patch :name, action: "update_name"
          get :notified_to_eu
          patch :notified_to_eu, action: "update_notified_to_eu"
          get :upload_file
          patch :file, action: "update_file"
          get :review
          patch :submission, action: "submit"
          get :confirmation, action: "confirmation_page"
        end
      end


      resources :contact_persons, controller: "responsible_persons/contact_persons", only: %i[new create edit update] do
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
    end
  end

  resource :my_account, only: [:show], controller: :my_account do
    resource :password, controller: :my_account_password, only: %i[show update]
    resource :name, controller: :my_account_name, only: %i[show update]
    resource :mobile_number, controller: :my_account_mobile_number, only: %i[show update]
    resource :email, controller: :my_account_email, only: %i[show update] do
      member do
        get :confirm
      end
    end
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
