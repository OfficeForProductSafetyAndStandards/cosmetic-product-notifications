# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  concern :document_attachable do
    resources :documents, controller: "documents" do
      collection do
        resources :new, controller: "documents_flow", only: %i[show new create update]
      end
    end
  end

  concern :image_attachable do
    resources :images, controller: "images" do
      collection do
        resources :new, controller: "images_flow", only: %i[show new create update]
      end
    end
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
      get :confirmation
      get :priority
      post :update_assignee
      post :update_priority
    end
    collection do
      resources :report, controller: "investigations/report", only: %i[show new create update]
      resources :question, controller: "investigations/question", only: %i[show new create update]
    end
    resources :activities, only: %i[index new create]
    resources :products, only: %i[new create], controller: "investigations/products" do
      collection do
        get :suggested
      end
      member do
        put :link, path: ''
        delete :unlink, path: ''
      end
    end
    resources :businesses, only: %i[new create], controller: "investigations/businesses" do
      collection do
        get :suggested
        post :companies_house
      end
      member do
        put :link, path: ''
        delete :unlink, path: ''
      end
    end
    resources :hazards, controller: "investigations/hazards", only: %i[new create show update] do
      collection do
        resources :new_hazard, controller: "investigations/hazards/new_hazard_flow", only: %i[show new create update]
        resources :edit_hazard, controller: "investigations/hazards/edit_hazard_flow", only: %i[show new create update]

        get :risk_level
        post :update_risk_level
      end
    end

    resources :correspondences, only: %i[show new create update], controller: "investigations/correspondence",
              concerns: %i[document_attachable]
    resources :incidents, controller: "investigations/incidents", only: %i[new create show update]
  end

  resources :businesses do
    collection do
      get :confirm_merge
      post :merge
      get :suggested
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

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  root to: redirect(path: "/investigations")
end
# rubocop:enable Metrics/BlockLength
