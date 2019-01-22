Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  resources :notification_files

  get '/send' => 'helloworld#send_email'

  root 'helloworld#index'
end
