class Organisation < Shared::Web::Organisation
end
Organisation.all if Rails.env.development?
