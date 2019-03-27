class Organisation < Shared::Web::Organisation
  has_many :teams, dependent: :nullify
end
Organisation.all if Rails.env.development?
