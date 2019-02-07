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
    resources :notification_files, controller: "responsible_persons/notification_files", only: %i[new create]
    resources :notifications, controller: "responsible_persons/notifications", only: %i[index]
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

  match "/403", to: "errors#forbidden", via: :all
end
