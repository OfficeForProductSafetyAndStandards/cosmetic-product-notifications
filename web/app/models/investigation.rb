require_dependency 'audit_activity/business'
require_dependency 'audit_activity/investigation'
require_dependency 'audit_activity/product'

class Investigation < ApplicationRecord
  include Searchable
  include Documentable
  include UserService
  include Investigations::DisplayTextHelper

  validates :title, presence: true, on: :question_details
  validate :validate_assignment

  after_save :send_assignee_email

  index_name [Rails.env, "investigations"].join("_")

  settings do
    mappings do
      indexes :status, type: :keyword
    end
  end

  default_scope { order(updated_at: :desc) }

  belongs_to_active_hash :assignee, class_name: "User", optional: true

  has_many :investigation_products, dependent: :destroy
  has_many :products, through: :investigation_products, after_add: :create_audit_activity_for_product

  has_many :investigation_businesses, dependent: :destroy
  has_many :businesses, through: :investigation_businesses, after_add: :create_audit_activity_for_business

  has_many :activities, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :investigation

  has_many :incidents, dependent: :destroy

  has_many :correspondences, dependent: :destroy

  has_many_attached :documents
  has_many_attached :images

  has_one :source, as: :sourceable, dependent: :destroy
  has_one :reporter, dependent: :destroy
  has_one :hazard, dependent: :destroy

  after_create :create_audit_activity_for_case

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

  def create_audit_activity_for_case
    ::AuditActivity::Investigation::Add.from(self)
  end

  def create_audit_activity_for_product product
    ::AuditActivity::Product::Add.from(product, self)
  end

  def create_audit_activity_for_business business
    ::AuditActivity::Business::Add.from(business, self)
  end

  def get_title
    #TODO Once MSPSDS-528 is merged, add Hazard part of title. Format is "#{products portion} - #{hazard overview}"
    build_title_products_portion.presence || "Untitled #{case_question_text(self)}"
  end

private

  def validate_assignment
    if !new_record? && !assignee
      errors.add(:investigation, "cannot be unassigned")
    end
  end

  def send_assignee_email
    if saved_changes.key? :assignee_id
      NotifyMailer.assigned_investigation(self, assignee.full_name, assignee.email).deliver_later
    end
  end

  def build_title_products_portion
    case products.length
    when 0
      ''
    when 1
      product = products[0]
      [product.brand, product.model, product.product_type].compact.join(", ")
    else
      count = "#{products.length} Products"
      shared_property_values = %w(brand model type).map { |property| get_product_property_value_if_shared(property) }
      shared_property_values.unshift(count).compact.join(", ")
    end
  end

  def get_product_property_value_if_shared property_name
    first_product = products.first
    if products.all? { |product| product[property_name] == first_product[property_name] }
      first_product[property_name]
    end
  end
end

Investigation.import force: true # for auto sync model with elastic search
