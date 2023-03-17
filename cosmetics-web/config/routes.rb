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
Rails.application.routes.draw do
  mount GovukDesignSystem::Engine => "/", as: "govuk_design_system_engine"

  get "/sign_up", to: redirect("/")
  resource :password_changed, controller: "users/password_changed", only: :show, path: "password-changed"

  scope module: "secondary_authentication", path: "two-factor" do
    get "method", to: "method#new", as: :new_secondary_authentication_method
    post "method", to: "method#create", as: :secondary_authentication_method

    get "sms", to: "sms#new", as: :new_secondary_authentication_sms
    post "sms", to: "sms#create", as: :secondary_authentication_sms
    scope module: "sms", path: "sms" do
      get "not-received", to: "resend#new", as: :new_secondary_authentication_sms_resend
      post "not-received", to: "resend#create", as: :secondary_authentication_sms_resend
      get "setup", to: "setup#new", as: :new_secondary_authentication_sms_setup
      post "setup", to: "setup#create", as: :secondary_authentication_sms_setup
    end

    get "app", to: "app#new", as: :new_secondary_authentication_app
    post "app", to: "app#create", as: :secondary_authentication_app
    scope module: "app", path: "app" do
      get "setup", to: "setup#new", as: :new_secondary_authentication_app_setup
      post "setup", to: "setup#create", as: :secondary_authentication_app_setup
    end
  end

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
    end
    root "search/landing_page#index", as: :search_root

    scope module: "poison_centres", as: "poison_centre" do
      resources :notifications, param: :reference_number, only: %i[show]
      resource :notifications_search, path: "/notifications", controller: "notifications_search", only: %i[show]
      resource :ingredients_search, path: "/ingredients", controller: "ingredients_search", only: %i[show]
      resources :ingredients, path: "/ingredients-list", controller: "ingredients", only: %i[index]
      get "ingredients-list/responsible-persons", to: "ingredients#responsible_persons", as: :ingredients_responsible_persons
      get "ingredients-list/responsible-persons/:responsible_person_id/notifications", to: "ingredients#responsible_person_notifications", as: :ingredients_responsible_person_notifications
    end
    resources :users, only: [:update] do
      member do
        get "complete-registration", action: :complete_registration
        delete "complete-registration", action: :reset_complete_registration, as: :reset_complete_registration
        post "sign-out-before-accepting-invitation", action: :sign_out_before_accepting_invitation
      end
    end

    resource :dashboard, controller: "search/dashboard", only: %i[show]
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
    delete "account-security", to: "registration/account_security#reset", as: :registration_reset_account_security
    post "sign-out-before-confirming-email", to: "registration/new_accounts#sign_out_before_confirming_email"

    root "submit/landing_page#index", as: :submit_root

    resources :responsible_persons, only: %i[show edit update] do
      collection do
        resources :account, controller: "responsible_persons/account_wizard", only: %i[show update]
        get "select", to: "responsible_persons#select"
        post "select", to: "responsible_persons#change"
        get "products-redirect", to: "responsible_persons#products_page_redirect"
      end

      resources :nanomaterials, controller: :nanomaterial_notifications, only: %i[index show new create], shallow: true do
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

      resources :team_members, controller: "responsible_persons/team_members", only: %i[index] do
        collection do
          get :join
          post "sign-out-before-joining", action: :sign_out_before_joining
        end
      end

      resources :invitations, controller: "responsible_persons/invitations", only: %i[new create destroy] do
        member do
          get :cancel
          get :resend # Ideally this would be a PATCH action, but doesn't play well with redirection after 2FA triggered by the link to resend with patch method.
        end
      end
      resource :products, controller: "responsible_persons/search_notifications", path: "search-notifications", as: :search_notifications, only: %i[show]

      resource :ingredients, controller: "responsible_persons/search_ingredients", path: "search-ingredients", as: :search_ingredients, only: %i[show]

      resource :draft, controller: "responsible_persons/drafts", only: %i[new]
      get "draft-notifications", to: "responsible_persons/drafts#index", as: :draft_notifications
      get "archived-notifications", to: "responsible_persons/notifications#archived", as: :archived_notifications
      resources :notifications, param: :reference_number, controller: "responsible_persons/notifications", only: %i[index show new edit create] do
        resources :product, controller: "responsible_persons/notifications/product", only: %i[show update new]
        resources :product_kit, controller: "responsible_persons/notifications/product_kit", only: %i[show update new]
        resource :draft, controller: "responsible_persons/drafts", only: %i[show] do
          collection do
            get :review
            get :declaration
            post :accept
          end
          resource :delete_item, controller: "responsible_persons/delete_items", only: %i[show destroy]
          resource :delete_product_image, controller: "responsible_persons/delete_product_image", only: %i[destroy]
          resource :delete_nano_material, controller: "responsible_persons/delete_nano_materials", only: %i[show destroy]
        end

        resources :components, controller: "responsible_persons/notifications/components", only: %i[new create] do
          resources :build, controller: "responsible_persons/notifications/components/build", only: %i[show update new]
          resources :delete_ingredient, controller: "responsible_persons/notifications/components/delete_ingredients", only: %i[show destroy]
          resource :delete_ingredients_file, controller: "responsible_persons/notifications/components/delete_ingredients_file", only: %i[destroy]
        end

        resources :nanomaterials, controller: "responsible_persons/notifications/nanomaterials", only: %i[new create] do
          resources :build, controller: "responsible_persons/notifications/nanomaterials/build", only: %i[show update new]
        end

        resource :clone, controller: "responsible_persons/notifications/clone", only: %i[new create] do
          collection do
            get :confirm
          end
        end

        # The following actions should be `PATCH` once we no longer have bare links to them
        get :archive
        get :unarchive
      end

      resources :delete_notification, param: :reference_number, controller: "responsible_persons/delete_notification", only: [] do
        member do
          get :delete
          delete :destroy
        end
      end
    end
    resource :dashboard, controller: "submit/dashboard", only: %i[show]
  end

  resource :my_account, only: [:show], controller: :my_account do
    scope module: :my_account do
      resource :password, controller: :password, only: %i[edit update]
      resource :name, controller: :name, only: %i[edit update]
      resource :email, controller: :email, only: %i[edit update] do
        member do
          get :confirm
        end
      end
    end
  end

  resource :declaration, controller: :declaration, only: %i[show] do
    post :accept
  end

  namespace :guidance, as: "" do
    get :how_to_notify_nanomaterials, path: "how-to-notify-nanomaterials"
    get :how_to_prepare_images_for_notification, path: "how-to-prepare-images-for-notification"
    get :how_to_set_up_authenticator_app, path: "how-to-set-up-authenticator-app"
  end

  namespace :help, as: "" do
    get :accessibility_statement, path: "accessibility-statement"
    get :terms_and_conditions, path: "terms-and-conditions"
    get :privacy_notice, path: "privacy-notice"
    get :cookies_policy, path: "cookies"
    get :csv, path: "csv"
  end

  resource :cookie_form, only: [:create]

  get "frame_formulations", to: "frame_formulations#index"
  get "frame_formulations/:id/:sub_id/:name", to: "frame_formulations#show"

  get "invalid-account", to: "errors#invalid_account", as: :invalid_account

  match "/404", to: "errors#not_found", via: :all
  match "/403", to: "errors#forbidden", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/503", to: "errors#timeout", via: :all
end
