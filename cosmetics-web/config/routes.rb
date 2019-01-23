Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  resources :notification_files

  get 'helloworld' => 'helloworld#index'

  get '/send' => 'helloworld#send_email'

  root 'landing_page#index'

  get '/manual_entry' => 'manual_entry#create'

  resources :notifications, only: %i[edit] do
    member do
      get 'confirmation'
    end

    resources :manual_entry, only: %i[show update]
  end
end
