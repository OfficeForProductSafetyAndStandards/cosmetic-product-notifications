class Investigation < ApplicationRecord
  include Searchable
  include Documentable
  include UserService
  include AttachmentConcern

  attr_accessor :status_rationale

  validates :question_title, presence: true, on: :question_details
  validates :description, presence: true, on: %i[allegation_details question_details]
  validates :hazard_type, presence: true, on: :allegation_details
  validates :product_type, presence: true, on: :allegation_details

  validates_length_of :question_title, maximum: 1000
  validates_length_of :description, maximum: 1000

  after_save :send_assignee_email, :create_audit_activity_for_assignee,
             :create_audit_activity_for_status, :create_audit_activity_for_visibility

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
      only: %i[question_title description hazard_type product_type is_closed updated_at created_at assignee_id],
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

  def who_can_see
    return [] unless is_private

    # TODO MSPSDS-859: Replace hard-coded list with computation of users from organisations
    [assignee, source&.user].map { |u| u&.id }.uniq
  end

  def pretty_id
    id_string = id.to_s.rjust(8, '0')
    id_string.insert(4, "-")
  end

  def pretty_description
    "#{is_case ? 'Case' : 'Question'} #{pretty_id}"
  end

  def question_title_prefix
    question_type && !is_case ? question_type + ' ' : ''
  end

  def title
    self.is_case ? case_title : question_title
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
    %w[*.* pretty_id question_title description hazard_type product_type]
  end

  def self.fuzzy_fields
    %w[documents.* correspondences.* activities.* businesses.* products.* reporter.*
       tests.* question_title description hazard_type product_type]
  end

  def self.exact_fields
    %w[pretty_id]
  end

private

  def create_audit_activity_for_case
    is_case ? AuditActivity::Investigation::AddAllegation.from(self) : AuditActivity::Investigation::AddQuestion.from(self)
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

  def case_title
    title = build_title_from_products || ""
    title << " – #{hazard_type}" if hazard_type.present?
    title << " (no product specified)" if products.empty?
    title.presence || "Untitled case"
  end

  def send_assignee_email
    if saved_changes.key? :assignee_id
      NotifyMailer.assigned_investigation(id, assignee.full_name, assignee.email).deliver_later
    end
  end

  def build_title_from_products
    return product_type.dup if products.empty?

    title_components = []
    title_components << "#{products.length} Products" if products.length > 1
    title_components << get_product_property_value_if_shared(:brand)
    title_components << get_product_property_value_if_shared(:model)
    title_components << get_product_property_value_if_shared(:product_type)
    title_components.reject(&:blank?).join(", ")
  end

  def get_product_property_value_if_shared(property_name)
    first_product = products.first
    first_product[property_name] if products.drop(1).all? { |product| product[property_name] == first_product[property_name] }
  end
end

Investigation.import force: true if Rails.env.development? # for auto sync model with elastic search
