Rails.application.routes.draw do
  mount Shared::Web::Engine => "/shared-web"
end
