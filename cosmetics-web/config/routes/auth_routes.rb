get "/auth/one_login", to: "sessions#new", as: :login
get "/auth/one_login/callback", to: "sessions#create"
delete "/logout", to: "sessions#destroy", as: :logout
