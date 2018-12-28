class Organisation < ActiveHash::Base
  include ActiveHash::Associations

  field :id
  field :name
  field :path

  has_many :users

  def self.find_or_create(organisation)
    Organisation.find_by(id: organisation[:id]) || Organisation.create(organisation)
  end

  def self.all(options = {})
    begin
      self.data = KeycloakClient.instance.all_organisations
    rescue StandardError => error
      Rails.logger.error "Failed to fetch organisations from Keycloak: #{error.message}"
      self.data = nil
    end

    if options.has_key?(:conditions)
      where(options[:conditions])
    else
      @records ||= []
    end
  end
end
