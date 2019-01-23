Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'landing_page#index'

  resources :notification_files
  get '/manual_entry' => 'manual_entry#create'

  resources :notifications, only: %i[edit] do
    member do
      get 'confirmation'
    end

    resources :manual_entry, only: %i[show update]
  end
end
