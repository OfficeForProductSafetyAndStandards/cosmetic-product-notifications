# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root "landing_page#index"

  scope module: "poison_centres", as: "poison_centre" do
    resources :notifications, param: :reference_number, only: %i[index show]
  end

  resources :responsible_persons, only: %i[show] do
    collection do
      resources :account, controller: "responsible_persons/account_wizard", only: %i[show update]
    end

    resources :add_notification, controller: "responsible_persons/add_notification_wizard", only: %i[show new update]

    resources :team_members, controller: "responsible_persons/team_members", only: %i[index new create] do
      collection do
        get :join
      end
    end

    resources :email_verification_keys, path: "verify", controller: "responsible_persons/verification", param: :key, only: %i[show index] do
      collection do
        get :resend_email
      end
    end

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
      end

      member do
        post :confirm
      end
    end
  end

  resource :declaration, controller: :declaration, only: %i[show] do
    post :accept
  end

  resource :dashboard, controller: :dashboard, only: %i[show]

  namespace :help, as: "" do
    get :terms_and_conditions, path: "terms-and-conditions"
    get :privacy_notice, path: "privacy-notice"
  end

  match "/404", to: "errors#not_found", via: :all
  match "/403", to: "errors#forbidden", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  # This is the page that will show for timeouts, currently showing the same as an internal error
  match "/503", to: "errors#timeout", via: :all
end
# rubocop:enable Metrics/BlockLength
