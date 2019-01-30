Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  resources :notification_files

  resources :responsible_persons do
    resources :notifications, controller: "responsible_persons/notifications"
    resources :team_members, controller: "responsible_persons/team_members"
  end


  get '/send' => 'helloworld#send_email'
  root 'helloworld#index'

  get '/manual_entry' => 'manual_entry#create'

  resources :notifications, only: %i[edit] do
    member do
      get 'confirmation'
    end

    resources :manual_entry, only: %i[show update]
  end
end
