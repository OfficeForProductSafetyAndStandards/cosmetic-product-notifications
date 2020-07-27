class SearchUser < User
  belongs_to :organisation

  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy
  has_many :responsible_persons, through: :responsible_person_users

  has_one :user_attributes, dependent: :destroy

  # Getters and setters for each UserAttributes column should be added here so they can be accessed directly via delegation.
  delegate :has_accepted_declaration?, :has_accepted_declaration!, to: :get_user_attributes

  attr_accessor :access_token

  def has_role?(role)
    access_token = self.class.current.access_token if current_user?
    KeycloakClient.instance.has_role?(id, role, access_token)
  end

  def responsible_persons
    # ActiveHash does not support has_many through: associations
    # Therefore adopt the workaround suggested here: https://github.com/zilkey/active_hash/issues/25
    ResponsiblePerson.find responsible_person_users.map(&:responsible_person_id)
  end

  def poison_centre_user?
    has_role? :poison_centre_user
  end

  def msa_user?
    has_role? :msa_user
  end

  def can_view_product_ingredients?
    !msa_user?
  end

  def self.current
    RequestStore.store[:current_user]
  end

  def self.current=(user)
    RequestStore.store[:current_user] = user
  end

private

  def current_user?
    self.class.current&.id == id
  end

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end
