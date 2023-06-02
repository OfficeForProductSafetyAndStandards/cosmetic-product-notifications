SupportPortal::Engine.routes.draw do
  resources :users, only: %i[index show]

  root "dashboard#index", as: :support_root
end
