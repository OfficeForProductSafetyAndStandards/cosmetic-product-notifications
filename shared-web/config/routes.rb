Shared::Web::Engine.routes.draw do
  resource :session, only: %i[new] do
    member do
      get :new
      get :signin
      delete :logout
    end
  end

  if Rails.env.development?
    get "components/:component" => "components_gallery#show"
  end
end
