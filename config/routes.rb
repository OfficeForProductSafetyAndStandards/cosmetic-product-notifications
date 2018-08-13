# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  resources :investigations do
    collection do
      get :table
    end

    member do
      post :close
      post :reopen
      get :assign
      post :update_assignee
    end
    resources :activities, shallow: true
  end

  resources :businesses do
    collection do
      get :search
      post :companies_house
    end
    resources :addresses, shallow: true
  end

  resources :products do
    collection do
      get :table
    end
  end

  devise_for :users, controllers: { invitations: "invitations" }
  resources :users

  get "homepage/index"
  root to: "homepage#index"
  get "/pages/:page" => "pages#show"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
# rubocop:enable Metrics/BlockLength
