Rails.application.routes.draw do
  resource :session, only: %i[new] do
    member do
      get :new
      get :signin
      delete :logout
    end
  end

  root 'helloworld#index'
end
