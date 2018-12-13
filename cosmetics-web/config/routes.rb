Rails.application.routes.draw do
  mount Shared::Web::Engine => '/engine', as: 'shared_engine'

  root 'helloworld#index'
end
