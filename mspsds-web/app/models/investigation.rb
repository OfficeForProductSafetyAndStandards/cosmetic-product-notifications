class Investigation < ApplicationRecord
  include Searchable
  include Documentable
  include AttachmentConcern
  include SanitizationHelper

  attr_accessor :status_rationale
  attr_accessor :visibility_rationale

  before_validation { trim_line_endings(:user_title, :description, :non_compliant_reason, :hazard_description) }
  validates :user_title, presence: true, on: :enquiry_details
  validates :description, presence: true, on: %i[allegation_details enquiry_details]
  validates :hazard_type, presence: true, on: :allegation_details
  validates :product_category, presence: true, on: :allegation_details
  validates :hazard_description, presence: true, on: :unsafe
  validates :hazard_type, presence: true, on: :unsafe
  validates :non_compliant_reason, presence: true, on: :non_compliant

  validates_length_of :user_title, maximum: 100
  validates_length_of :description, maximum: 10000
  validates_length_of :non_compliant_reason, maximum: 10000
  validates_length_of :hazard_description, maximum: 10000

  after_save :create_audit_activity_for_assignee,
             :create_audit_activity_for_status, :create_audit_activity_for_visibility

  # Elasticsearch index name must be declared in children and parent
  index_name [Rails.env, "investigations"].join("_")

  settings do
    mappings do
      indexes :status, type: :keyword
      indexes :assignable_id, type: :keyword
    end
  end

  default_scope { order(updated_at: :desc) }

  belongs_to :assignable, polymorphic: true, optional: true

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
  has_many :alerts, dependent: :destroy

  has_many_attached :documents

  has_one :source, as: :sourceable, dependent: :destroy
  has_one :complainant, dependent: :destroy

  before_create :assign_current_user_to_case, :add_pretty_id

  after_create :create_audit_activity_for_case, :send_confirmation_email

  def as_indexed_json(*)
    as_json(
      only: %i[user_title description hazard_type product_category is_closed assignable_id updated_at created_at pretty_id],
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
          only: %i[legal_name trading_name company_number]
        },
        products: {
          only: %i[category description name product_code product_type]
        },
        complainant: {
          only: %i[name phone_number email_address other_details]
        },
        tests: {
          only: %i[details result legislation]
        }
      }
    )
  end

  def assignee
    begin
      return User.find(assignable_id) if assignable_type == "User"
      return Team.find(assignable_id) if assignable_type == "Team"
    rescue StandardError
      return nil
    end
  end

  def assignee=(entity)
    self.assignable_id = entity.id
    self.assignable_type = "User" if entity.is_a?(User)
    self.assignable_type = "Team" if entity.is_a?(Team)
  end

  def status
    is_closed? ? "Closed" : "Open"
  end

  def pretty_visibility
    is_private ? ApplicationController.helpers.visibility_options[:private] : ApplicationController.helpers.visibility_options[:public]
  end

  def pretty_description
    "#{case_type.titleize}: #{pretty_id}"
  end

  def important_assignable_people
    people = [].to_set
    people << assignee if assignee.is_a? User
    people << User.current
    people
  end

  def past_assignees
    activities = AuditActivity::Investigation::UpdateAssignee.where(investigation_id: id)
    user_id_list = activities.map(&:assignable_id)
    User.where(id: user_id_list)
  end

  def important_assignable_teams
    teams = User.current.teams.to_set
    Team.get_visible_teams(User.current).each do |team|
      teams << team
    end
    teams << assignee if assignee.is_a? Team
    teams
  end

  def past_teams
    activities = AuditActivity::Investigation::UpdateAssignee.where(investigation_id: id)
    team_id_list = activities.map(&:assignable_id)
    Team.where(id: team_id_list)
  end

  def past_assignees_except_current
    past_assignees.reject { |user| user.id == assignee.id }
  end

  def self.highlighted_fields
    %w[*.* pretty_id user_title description hazard_type product_category]
  end

  def self.fuzzy_fields
    %w[documents.* correspondences.* activities.* businesses.* products.* complainant.*
       tests.* user_title description hazard_type product_category]
  end

  def self.exact_fields
    %w[pretty_id]
  end

  # To be implemented by children
  def title; end

  def case_type; end

  def reason_created
    return "Product reported because it is unsafe and non-compliant." if hazard_type.present? && non_compliant_reason.present?
    return "Product reported because it is unsafe." if hazard_type.present?

    "Product reported because it is non-compliant." if non_compliant_reason.present?
  end

  def has_non_compliant_reason
    if non_compliant_reason.empty?
      errors.add(:non_compliant_reason, "cannot be blank")
    end
  end

  def add_business(business, relationship)
    # Could not find a way to add a business to an investigation which allowed us to set the relationship value and
    # while still triggering the callback to add the audit activity. One possibility is to move the callback to the
    # InvestigationBusiness model.
    investigation_businesses.create!(business_id: business.id, relationship: relationship)
    create_audit_activity_for_business(business)
  end

  def to_param
    pretty_id
  end

  def add_pretty_id
    cases_before = Investigation.where("created_at < ? AND created_at > ?", created_at, created_at.beginning_of_month).count
    self.pretty_id = "#{created_at.strftime('%y%m')}-%04d" % (cases_before + 1)
  end

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
    if saved_changes.key?(:is_private) || visibility_rationale.present?
      AuditActivity::Investigation::UpdateVisibility.from(self)
    end
  end

  def create_audit_activity_for_assignee
    if (saved_changes.key? :assignable_id) || (saved_changes.key? :assignable_type)
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
    self.source = UserSource.new(user: User.current) if self.source.blank? && User.current
  end

  def send_confirmation_email
    if User.current
      NotifyMailer.investigation_created(pretty_id,
                                       User.current.full_name,
                                       User.current.email,
                                       title,
                                       case_type).deliver_later
    end
  end
end

Investigation.import force: true if Rails.env.development? # for auto sync model with elastic search
