class Investigation < ApplicationRecord
  include Documentable
  include AttachmentConcern
  include SanitizationHelper
  include InvestigationElasticsearch

  attr_accessor :status_rationale
  attr_accessor :visibility_rationale
  attr_accessor :assignee_rationale

  before_validation { trim_line_endings(:user_title, :description, :non_compliant_reason, :hazard_description) }

  validates :description, presence: true, on: :update
  validates :assignable_id, presence: { message: "Select assignee" }, on: :update

  validates_length_of :user_title, maximum: 100
  validates_length_of :description, maximum: 10000
  validates_length_of :non_compliant_reason, maximum: 10000
  validates_length_of :hazard_description, maximum: 10000

  after_update :create_audit_activity_for_assignee, :create_audit_activity_for_status,
               :create_audit_activity_for_visibility, :create_audit_activity_for_summary

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

  before_create :set_source_to_current_user, :assign_to_current_user, :add_pretty_id

  after_create :create_audit_activity_for_case, :send_confirmation_email

  def assignee
    begin
      return User.find(assignable_id) if assignable_type == "User"
      return Team.find(assignable_id) if assignable_type == "Team"
    rescue StandardError
      return nil
    end
  end

  def assignee=(entity)
    self.assignable_id = entity&.id
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

  # To be implemented by children
  def title; end

  def creator_id
    @investigation.source.user_id
  end

  def case_type; end

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

  def child_should_be_displayed?
    # This method is responsible for white-list access for assignee and their team, as described in
    # https://regulatorydelivery.atlassian.net/wiki/spaces/PSD/pages/598933517/Approach+to+case+sensitivity
    return true if (self.assignee.is_a? Team) && self.assignee.users.include?(User.current)
    return true if (self.assignee.is_a? User) && (self.assignee.teams & User.current.teams).any?

    false
  end

  def reason_created
    return "Product reported because it is unsafe and non-compliant." if hazard_description && non_compliant_reason
    return "Product reported because it is unsafe." if hazard_description

    "Product reported because it is non-compliant."
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
    # TODO: User.current check is here to avoid triggering activity and emails from migrations
    # Can be safely removed once the migration PopulateAssigneeAndDescription has run
    if ((saved_changes.key? :assignable_id) || (saved_changes.key? :assignable_type)) && User.current
      AuditActivity::Investigation::UpdateAssignee.from(self)
    end
  end

  def create_audit_activity_for_summary
    # TODO: User.current check is here to avoid triggering activity and emails from migrations
    # Can be safely removed once the migration PopulateAssigneeAndDescription has run
    if saved_changes.key?(:description) && User.current
      AuditActivity::Investigation::UpdateSummary.from(self)
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

  def set_source_to_current_user
    self.source = UserSource.new(user: User.current) if source.blank? && User.current
  end

  def creator_id
    self.source&.user_id
  end

  def assign_to_current_user
    self.assignee = User.current if assignee.blank? && User.current
  end

  def send_confirmation_email
    if User.current
      NotifyMailer.investigation_created(
        pretty_id,
        User.current.name,
        User.current.email,
        title,
        case_type
      ).deliver_later
    end
  end
end

Investigation.import force: true if Rails.env.development? # for auto sync model with elastic search
