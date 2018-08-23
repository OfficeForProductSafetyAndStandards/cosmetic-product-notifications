# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  concern :image_attachable do
    resources :images
  end

  resources :investigations, concerns: :image_attachable do
    member do
      get :status
      get :assign
      post :update_assignee
    end
    resources :activities, only: %i[index new create]
    resources :products, only: %i[index new create destroy], controller: "investigations/products" do
      collection do
        get :search
        get :suggested
        post :add
      end
    end
    resources :businesses, only: %i[index new create destroy], controller: "investigations/businesses" do
      collection do
        get :search
        get :suggested
        post :add
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

  resources :products, concerns: :image_attachable do
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
