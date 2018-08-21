# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  resources :investigations do
    member do
      post :close
      post :reopen
      get :assign
      post :update_assignee
    end
    resources :activities, shallow: true
    resources :products, only: %i[index new create], controller: "investigations/products" do
      collection do
        get :suggested
        post :add_product
      end
    end
    resources :businesses, only: %i[index new create], controller: "investigations/businesses" do
      collection do
        get :suggested
        post :add_business
        post :companies_house
      end
    end
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
      get :suggested
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
