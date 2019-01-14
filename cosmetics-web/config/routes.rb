Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'helloworld#index'

  get '/send' => 'helloworld#send_email'
  post '/' => 'helloworld#upload_file'

  resources :manual_entry, only: %i[show create update]
  get '/manual_entry' => 'manual_entry#create'
end
