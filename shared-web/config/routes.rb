Shared::Web::Engine.routes.draw do
  if Rails.env.development?
    get "components/:component" => "components_gallery#show"
  end
end
