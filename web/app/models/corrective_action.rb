class CorrectiveAction < ApplicationRecord
  include DateConcern

  belongs_to :investigation
  belongs_to :business
  belongs_to :product

  has_many_attached :documents

  def get_date_key
    :date_decided
  end

  validate :date_decided_cannot_be_in_the_future

  validates :summary, presence: true
  validates :date_decided, presence: true
  validates :investigation, presence: true
  validates :business, presence: true
  validates :product, presence: true

  validates_length_of :summary, :maximum => 1000
  validates_length_of :details, :maximum => 1000

  after_create :create_audit_activity

  def date_decided_cannot_be_in_the_future
    errors.add(:date_decided, "can't be in the future") if date_decided.present? && date_decided > Time.zone.today
  end

  def create_audit_activity
    AuditActivity::CorrectiveAction::Add.from(self)
  end
end
