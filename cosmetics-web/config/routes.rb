Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

  get 'helloworld' => 'helloworld#index'

  root 'landing_page#index'
end
