Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  root 'helloworld#index'

  get '/send' => 'helloworld#send_email'
  post '/' => 'helloworld#upload_file'
end
