class Organisation < Shared::Web::Organisation
  has_many :teams, dependent: :nullify
end
Organisation.load if Rails.env.development?
