SupportPortal::Engine.routes.draw do
  root "dashboard#index", as: :support_root

  resources :notifications, only: %i[index show] do
    collection do
      get "search"
    end

    member do
      delete "delete"
      patch "undelete"
      put "undelete"
    end
  end

  resources :history, only: %i[index]

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

  resource :invite_support_user, path: "invite-support-user", only: %i[new create]

  resources :responsible_persons, path: "responsible-persons", only: %i[index show] do
    member do
      get "edit-name"
      patch "update-name"
      put "update-name"
      get "edit-address"
      patch "update-address"
      put "update-address"
      get "edit-business-type"
      patch "update-business-type"
      put "update-business-type"
      get "edit-assigned-contact-name/:assigned_contact_id", to: "responsible_persons#edit_assigned_contact_name", as: :edit_assigned_contact_name
      patch "update-assigned-contact-name/:assigned_contact_id", to: "responsible_persons#update_assigned_contact_name", as: :update_assigned_contact_name
      put "update-assigned-contact-name/:assigned_contact_id", to: "responsible_persons#update_assigned_contact_name"
      get "edit-assigned-contact-email/:assigned_contact_id", to: "responsible_persons#edit_assigned_contact_email", as: :edit_assigned_contact_email
      patch "update-assigned-contact-email/:assigned_contact_id", to: "responsible_persons#update_assigned_contact_email", as: :update_assigned_contact_email
      put "update-assigned-contact-email/:assigned_contact_id", to: "responsible_persons#update_assigned_contact_email"
      get "edit-assigned-contact-phone-number/:assigned_contact_id", to: "responsible_persons#edit_assigned_contact_phone_number", as: :edit_assigned_contact_phone_number
      patch "update-assigned-contact-phone-number/:assigned_contact_id", to: "responsible_persons#update_assigned_contact_phone_number", as: :update_assigned_contact_phone_number
      put "update-assigned-contact-phone-number/:assigned_contact_id", to: "responsible_persons#update_assigned_contact_phone_number"
    end
  end
end
