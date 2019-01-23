Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'landing_page#index'

  get '/manual_entry' => 'manual_entry#create'

  resources :notification_files

  resources :notifications, only: %i[new edit] do
    member do
      get 'confirmation'
    end

    resources :build, controller: :notification_build, only: %i[show update new]
  end

  resources :responsible_persons do
    resources :notifications, controller: "responsible_persons/notifications", only: %i[index]
    resources :team_members, controller: "responsible_persons/team_members", only: %i[index]
  end
  
  resources :components do
    resources :build, controller: :component_build, only: %i[show update new]
  end
end
