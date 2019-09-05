class Organisation < Shared::Web::Organisation
  include ActiveHashSafeLoadable
  has_many :teams, dependent: :nullify

  def self.load(force: false)
    begin
      self.safe_load(Shared::Web::KeycloakClient.instance.all_organisations(force: force), data_name: 'organisations')
    rescue StandardError => e
      Rails.logger.error "Failed to fetch organisations from Keycloak: #{e.message}"
      self.data = nil
    end
  end
end
Organisation.load if Rails.env.development?
