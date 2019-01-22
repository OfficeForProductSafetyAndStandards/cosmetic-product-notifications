class Investigation < ApplicationRecord
  include Searchable
  include Documentable
  include AttachmentConcern
  include UserService

  attr_accessor :status_rationale

  validates_length_of :user_title, maximum: 1000
  validates_length_of :description, maximum: 1000

  after_save :send_assignee_email, :create_audit_activity_for_assignee,
             :create_audit_activity_for_status, :create_audit_activity_for_visibility

  # Elasticsearch index name must be declared in children and parent
  index_name [Rails.env, "investigations"].join("_")

  settings do
    mappings do
      indexes :status, type: :keyword
      indexes :assignee_id, type: :keyword
    end
  end

  default_scope { order(updated_at: :desc) }

  belongs_to_active_hash :assignee, class_name: "User", optional: true

  has_many :investigation_products, dependent: :destroy
  has_many :products, through: :investigation_products,
           after_add: :create_audit_activity_for_product,
           after_remove: :create_audit_activity_for_removing_product

  has_many :investigation_businesses, dependent: :destroy
  has_many :businesses, through: :investigation_businesses,
           after_add: :create_audit_activity_for_business,
           after_remove: :create_audit_activity_for_removing_business

  has_many :activities, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :investigation

  has_many :corrective_actions, dependent: :destroy
  has_many :correspondences, dependent: :destroy
  has_many :tests, dependent: :destroy

  has_many_attached :documents

  has_one :source, as: :sourceable, dependent: :destroy
  has_one :reporter, dependent: :destroy

  before_create :assign_current_user_to_case

  after_create :create_audit_activity_for_case

  def as_indexed_json(*)
    as_json(
      methods: %i[pretty_id],
      only: %i[user_title description hazard_type product_type is_closed updated_at created_at assignee_id],
      include: {
        documents: {
          only: [],
          methods: %i[title description filename]
        },
        correspondences: {
          only: %i[correspondent_name details email_address email_subject overview phone_number email_subject]
        },
        activities: {
          methods: :search_index,
          only: []
        },
        businesses: {
          only: %i[company_name company_number]
        },
        products: {
          only: %i[batch_number brand description gtin model name]
        },
        reporter: {
          only: %i[name phone_number email_address other_details]
        },
        tests: {
          only: %i[details result legislation]
        }
      }
    )
  end

  def status
    is_closed? ? "Closed" : "Open"
  end

  def pretty_visibility
    is_private ? ApplicationController.helpers.visibility_options[:private] : ApplicationController.helpers.visibility_options[:public]
  end

  def visible_to(user)
    return true unless is_private
    return true if assignee.present? && (assignee&.organisation == user.organisation)
    return true if source&.user&.present? && (source&.user&.organisation == user.organisation)
    return true if user.is_opss?

    false
  end

  def pretty_id
    id_string = id.to_s.rjust(8, '0')
    id_string.insert(4, "-")
  end

  def pretty_description
    "#{case_type.titleize}: #{pretty_id}"
  end

  def past_assignees
    activities = AuditActivity::Investigation::UpdateAssignee.where(investigation_id: id)
    user_id_list = activities.map(&:assignee_id)
    User.where(id: user_id_list.uniq)
  end

  def past_assignees_except_current
    past_assignees.reject { |user| user.id == assignee.id }
  end

  def self.highlighted_fields
    %w[*.* pretty_id user_title description hazard_type product_type]
  end

  def self.fuzzy_fields
    %w[documents.* correspondences.* activities.* businesses.* products.* reporter.*
       tests.* user_title description hazard_type product_type]
  end

  def self.exact_fields
    %w[pretty_id]
  end

  # To be implemented by children
  def title; end

  def case_type; end

private

  def create_audit_activity_for_case
    # To be implemented by children
  end

  def create_audit_activity_for_status
    if saved_changes.key?(:is_closed) || status_rationale.present?
      AuditActivity::Investigation::UpdateStatus.from(self)
    end
  end

  def create_audit_activity_for_visibility
    if saved_changes.key?(:is_private)
      AuditActivity::Investigation::UpdateVisibility.from(self)
    end
  end

  def create_audit_activity_for_assignee
    if saved_changes.key? :assignee_id
      AuditActivity::Investigation::UpdateAssignee.from(self)
    end
  end

  def create_audit_activity_for_product(product)
    AuditActivity::Product::Add.from(product, self)
  end

  def create_audit_activity_for_removing_product(product)
    AuditActivity::Product::Destroy.from(product, self)
  end

  def create_audit_activity_for_business(business)
    AuditActivity::Business::Add.from(business, self)
  end

  def create_audit_activity_for_removing_business(business)
    AuditActivity::Business::Destroy.from(business, self)
  end

  def assign_current_user_to_case
    self.source = UserSource.new(user: current_user) if self.source.blank? && current_user.present?
  end

  def send_assignee_email
    if saved_changes.key? :assignee_id
      NotifyMailer.assigned_investigation(id, assignee.full_name, assignee.email).deliver_later
    end
  end
end

Investigation.import force: true if Rails.env.development? # for auto sync model with elastic search
