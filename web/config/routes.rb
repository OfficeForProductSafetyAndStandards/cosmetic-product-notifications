# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  concern :document_attachable do
    resources :documents, controller: "documents" do
      collection do
        resources :new, controller: "documents_flow", only: %i[show new create update]
      end
      member do
        get :remove
      end
    end
  end

  concern :image_attachable do
    resources :images, controller: "images" do
      collection do
        resources :new, controller: "images_flow", only: %i[show new create update]
      end
      member do
        get :remove
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

  resources :question, controller: "investigations/question", only: %i[show new create update]
  resources :allegation, controller: "investigations/allegation", only: %i[show new create update]

  resources :investigations, path: "cases", only: %i[index show new create update],
            concerns: %i[document_attachable image_attachable] do
    member do
      get :status
      get :assign
    end
    resources :activities, controller: "investigations/activities", only: %i[create new] do
      collection do
        get :comment
      end
    end
    resources :products, only: %i[new create], controller: "investigations/products" do
      collection do
        get :suggested
      end
      member do
        put :link, path: ''
        get :remove
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
        get :remove
        delete :unlink, path: ''
      end
    end

    resources :corrective_actions, controller: "investigations/corrective_actions", only: %i[show new create update]
    resources :correspondences, only: %i[show new create update], controller: "investigations/correspondence",
              concerns: %i[document_attachable]
    resources :emails, controller: "investigations/emails", only: %i[show new create update]
    resources :phone_calls, controller: "investigations/phone_calls", only: %i[show new create update]
    resources :meetings, controller: "investigations/meetings", only: %i[show new create update]
    resources :tests, controller: "investigations/tests", only: %i[show create update] do
      collection do
        get :new_request
        get :new_result
      end
    end
  end

  resources :businesses, concerns: %i[document_attachable image_attachable] do
    collection do
      get :suggested
      post :companies_house
    end
    resources :locations, shallow: true do
      member do
        get :remove
      end
    end
  end

  resources :products, concerns: %i[document_attachable image_attachable] do
    collection do
      get :suggested
    end
  end

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  # This is the page that will show for timeouts, currently showing the same as an internal error
  match "/503", to: "errors#timeout", via: :all

  mount PgHero::Engine, at: "pghero"

  root to: redirect(path: "/cases")
end
# rubocop:enable Metrics/BlockLength
