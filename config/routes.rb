Rails.application.routes.draw do
  resources :investigations do
    member do
      post :close
      post :reopen
    end
    resources :activities, shallow: true
  end
  resources :products
  devise_for :users, controllers: { invitations: "invitations" }
  resources :users

  get "homepage/index"
  root to: "homepage#index"
  get "/pages/:page" => "pages#show"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
