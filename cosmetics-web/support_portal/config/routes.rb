SupportPortal::Engine.routes.draw do
  resources :users, only: [:index]

  root "dashboard#index", as: :support_root
end
