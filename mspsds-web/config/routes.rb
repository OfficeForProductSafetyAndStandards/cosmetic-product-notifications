# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount Shared::Web::Engine => '/', as: 'shared_engine'

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

  resources :enquiry, controller: "investigations/enquiry", only: %i[show new create update]
  resources :allegation, controller: "investigations/allegation", only: %i[show new create update]
  resources :project, controller: "investigations/project", only: %i[new create]
  resources :ts_investigation, controller: "investigations/ts_investigations", only: %i[show new create update]

  resources :investigations, path: "cases", only: %i[index show new], param: :pretty_id,
            concerns: %i[document_attachable] do
    member do
      put :status
      get :status
      put :assign
      get :assign
      put :visibility
      get :visibility
      put :edit_summary
      get :edit_summary
    end
    resources :activities, controller: "investigations/activities", only: %i[create new] do
      collection do
        get :comment
      end
    end
    resources :products, only: %i[new create], controller: "investigations/products" do
      member do
        put :link, path: ''
        get :remove
        delete :unlink, path: ''
      end
    end
    resources :businesses, only: %i[update show new create], controller: "investigations/businesses" do
      member do
        get :remove
        delete :unlink, path: ''
      end
    end

    resources :corrective_actions, controller: "investigations/corrective_actions", only: %i[show new create update]
    resources :emails, controller: "investigations/emails", only: %i[show new create update]
    resources :phone_calls, controller: "investigations/phone_calls", only: %i[show new create update]
    resources :meetings, controller: "investigations/meetings", only: %i[show new create update]
    resources :alerts, controller: "investigations/alerts", only: %i[show new create update]
    resources :tests, controller: "investigations/tests", only: %i[show create update] do
      collection do
        get :new_request
        get :new_result
      end
    end
  end

  resources :businesses, except: %i[new create destroy], concerns: %i[document_attachable] do
    resources :locations do
      member do
        get :remove
      end
    end
    resources :contacts do
      member do
        get :remove
      end
    end
  end

  resources :products, except: %i[new create destroy], concerns: %i[document_attachable]

  get "your-teams" => "teams#index"
  resources :teams, only: %i[index show] do
    member do
      get :invite_to, path: "invite"
      put :invite_to, path: "invite"
    end
  end

  match "/404", to: "errors#not_found", via: :all
  match "/403", to: "errors#forbidden", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  # This is the page that will show for timeouts, currently showing the same as an internal error
  match "/503", to: "errors#timeout", via: :all

  mount PgHero::Engine, at: "pghero"

  root to: "homepage#show"
end
# rubocop:enable Metrics/BlockLength
