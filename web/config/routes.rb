Rails.application.routes.draw do
  resources :hazards
  concern :document_attachable do
    resources :documents
  end

  concern :image_attachable do
    resources :images
  end

  resource :session, only: %i[new] do
    member do
      get :new
      get :signin
      delete :logout
    end
  end

  resources :investigations, concerns: %i[document_attachable image_attachable] do
    member do
      get :status
      get :assign
      post :update_assignee
    end
    collection do
      resources :report, controller: "investigations/report", only: %i[show new create update]
    end
    resources :activities, only: %i[index new create]
    resources :products, only: %i[index new create destroy], controller: "investigations/products" do
      collection do
        get :suggested
        post :add
      end
    end
    resources :businesses, only: %i[index new create destroy], controller: "investigations/businesses" do
      collection do
        get :suggested
        post :add
        post :companies_house
      end
    end
    resources :hazards, controller: "investigations/hazards" do
      collection do
        get :risk_level
        post :update_risk_level
      end
    end
  end

  resources :businesses do
    collection do
      get :confirm_merge
      get :search
      post :merge
      post :companies_house
    end
    resources :addresses, shallow: true
  end

  resources :products, concerns: %i[document_attachable image_attachable] do
    collection do
      get :confirm_merge
      post :merge
      get :suggested
    end
  end

  resources :users, only: %i[index]

  root to: redirect(path: "/investigations")
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
