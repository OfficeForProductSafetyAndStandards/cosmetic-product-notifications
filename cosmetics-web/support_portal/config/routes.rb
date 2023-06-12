SupportPortal::Engine.routes.draw do
  root "dashboard#index", as: :support_root

  resources :notifications, only: %i[index show] do
    member do
      delete "delete"
      patch "undelete"
      put "undelete"
    end
  end

  resources :account_administration, path: "account-admin", only: %i[index show] do
    member do
      get "edit-name"
      patch "update-name"
      put "update-name"
      get "edit-email"
      patch "update-email"
      put "update-email"
      get "reset-account"
      delete "reset"
      get "edit-responsible-persons"
      get "delete-responsible-person-user/:responsible_person_user_id/confirm", to: "account_administration#delete_responsible_person_user_confirm", as: :confirm_delete_responsible_person_user
      delete "delete-responsible-person-user/:responsible_person_user_id", to: "account_administration#delete_responsible_person_user", as: :delete_responsible_person_user
    end
  end
end
