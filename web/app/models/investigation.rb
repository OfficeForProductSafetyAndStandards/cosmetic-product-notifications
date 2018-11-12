class Investigation < ApplicationRecord
  include Searchable
  include Documentable
  include UserService

  attr_accessor :priority_rationale

  enum priority: %i[low medium high]

  validates :question_title, presence: true, on: :question_details
  validate :validate_assignment, :validate_priority

  after_save :send_assignee_email, :create_audit_activity_for_priority, :create_audit_activity_for_assignee

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

  before_create :assign_current_user_to_case

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

  def question_title_prefix
    question_type && !is_case ? question_type + ' ' : ''
  end

  def title
    self.is_case ? case_title : question_title
  end

  def past_assignees
    activities = AuditActivity::Investigation::UpdateAssignee.where(investigation_id: id)
    user_id_list = activities.map(&:assignee_id)
    users = User.where(id: user_id_list.uniq)
    users
  end

  def past_assignees_except_current
    past_assignees.reject { |user| user.id == assignee.id }
  end

private

  def create_audit_activity_for_case
    AuditActivity::Investigation::Add.from(self)
    AuditActivity::Report::Add.from(self.reporter, self) if self.reporter
  end

  def create_audit_activity_for_priority
    if saved_changes.key?(:priority) || priority_rationale.present?
      AuditActivity::Investigation::UpdatePriority.from(self)
    end
  end

  def create_audit_activity_for_assignee
    if saved_changes.key? :assignee_id
      AuditActivity::Investigation::UpdateAssignee.from(self)
    end
  end

  def create_audit_activity_for_product product
    AuditActivity::Product::Add.from(product, self)
  end

  def create_audit_activity_for_business business
    AuditActivity::Business::Add.from(business, self)
  end

  def assign_current_user_to_case
    return if current_user.blank?

    self.source = UserSource.new(user: current_user) if self.source.blank?
    self.assignee = current_user
  end

  def case_title
    title = [build_title_products_portion, build_title_hazard_portion].reject(&:blank?).join(" - ")
    title.presence || "Untitled case"
  end

  def validate_assignment
    if assignee_id_was.present? && !assignee
      errors.add(:assignee, "cannot be blank")
    end
  end

  def validate_priority
    if !priority && priority_rationale
      errors.add(:priority, "has not been selected")
    end
  end

  def send_assignee_email
    if saved_changes.key? :assignee_id
      NotifyMailer.assigned_investigation(self, assignee.full_name, assignee.email).deliver_later
    end
  end

  def build_title_products_portion
    return "" if products.empty?

    shared_property_values = %w(brand model product_type).map { |property| get_property_value_if_shared property }
    title = shared_property_values.reject(&:blank?).join(", ")
    products.length > 1 ? "#{products.length} Products, ".concat(title) : title
  end

  def build_title_hazard_portion
    hazard&.hazard_type.presence
  end

  def get_property_value_if_shared property_name
    first_product = products.first
    if products.all? { |product| product[property_name] == first_product[property_name] }
      first_product[property_name]
    end
  end
end

Investigation.import force: true # for auto sync model with elastic search
