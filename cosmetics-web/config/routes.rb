Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'landing_page#index'

  get '/manual_entry' => 'manual_entry#create'

  resources :notifications, only: %i[edit] do
    member do
      get 'confirmation'
    end

    resources :manual_entry, only: %i[show update]
  end

  resources :responsible_persons do
    resources :notification_files, controller: "responsible_persons/notification_files"
    resources :notifications, controller: "responsible_persons/notifications", only: %i[index]
    resources :team_members, controller: "responsible_persons/team_members", only: %i[index]
  end
end
