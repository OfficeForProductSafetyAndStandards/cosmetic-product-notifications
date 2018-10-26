class Investigation < ApplicationRecord
  include Searchable
  include Documentable

  index_name [Rails.env, "investigations"].join("_")

  settings do
    mappings do
      indexes :status, type: :keyword
    end
  end

  default_scope { order(updated_at: :desc) }

  belongs_to_active_hash :assignee, class_name: "User", optional: true

  has_many :investigation_products, dependent: :destroy
  has_many :products, through: :investigation_products, after_add: :create_audit_activity

  has_many :investigation_businesses, dependent: :destroy
  has_many :businesses, through: :investigation_businesses

  has_many :activities, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :investigation

  has_many :incidents, dependent: :destroy

  has_many_attached :documents
  has_many_attached :images

  has_one :source, as: :sourceable, dependent: :destroy
  has_one :reporter, dependent: :destroy

  enum risk_level: %i[low medium serious severe], _suffix: true

  enum sensitivity: %i[low medium high], _suffix: true

  def as_indexed_json(*)
    as_json.merge(status: status.downcase)
  end

  def status
    is_closed? ? "Closed" : "Open"
  end

  def pretty_id
    id_string = id.to_s.rjust(8, '0')
    id_string.insert(4, "-")
  end

  def create_audit_activity product
    user_info = KeycloakClient.instance.user_info
    user = User.find_or_create(user_info)
    AuditActivity.create(
        title: product.name,
        subtitle_slug: "Product added",
        product: product,
        description: "Product desc",
        source: UserSource.new(user: user),
        investigation: self)
  end
end

Investigation.import force: true # for auto sync model with elastic search
