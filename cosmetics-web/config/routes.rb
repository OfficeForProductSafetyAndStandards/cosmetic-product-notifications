# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'landing_page#index'

  resources :notifications, only: %i[new edit] do
    member do
      get :confirmation
    end

    resources :build, controller: :notification_build, only: %i[show update new]
  end

  resources :responsible_persons, only: %i[show] do
    resources :notification_files, controller: "responsible_persons/notification_files", only: %i[new create destroy show] do
      collection do
        delete :destroy_all
      end
    end
    resources :notifications, param: :reference_number, controller: "responsible_persons/notifications", only: %i[index]
    resources :team_members, controller: "responsible_persons/team_members", only: %i[index]

    collection do
      resources :account, controller: "responsible_persons/account_wizard", only: %i[show update] do
        collection do
          get :create_or_join_existing
          get :join_existing
        end
      end
    end
  end

  resources :components do
    resources :build, controller: :component_build, only: %i[show update new]
  end

  match "/404", to: "errors#not_found", via: :all
  match "/403", to: "errors#forbidden", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  # This is the page that will show for timeouts, currently showing the same as an internal error
  match "/503", to: "errors#timeout", via: :all
end
# rubocop:enable Metrics/BlockLength
