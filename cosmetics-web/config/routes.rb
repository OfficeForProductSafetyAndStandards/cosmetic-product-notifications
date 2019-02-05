Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'landing_page#index'

  get '/manual_entry' => 'manual_entry#create'

  resources :notification_files

  resources :notifications, only: %i[edit] do
    member do
      get :confirmation
    end

    resources :manual_entry, only: %i[show update]
  end

  resources :responsible_persons, only: %i[show] do
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
end
