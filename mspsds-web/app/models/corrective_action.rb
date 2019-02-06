class CorrectiveAction < ApplicationRecord
  include DateConcern

  attribute :related_file

  belongs_to :investigation
  belongs_to :business, optional: true
  belongs_to :product

  has_many_attached :documents

  def get_date_key
    :date_decided
  end


  validates :summary, presence: true
  validates :date_decided, presence: true
  validate :date_decided_cannot_be_in_the_future
  validates :investigation, presence: true
  validates :product, presence: true
  validates :legislation, presence:true
  validate :related_file_validation, on: :ts_flow

  validates_length_of :summary, maximum: 1000
  validates_length_of :details, maximum: 1000

  after_create :create_audit_activity

  def date_decided_cannot_be_in_the_future
    errors.add(:date_decided, "can't be in the future") if date_decided.present? && date_decided > Time.zone.today
  end

  def create_audit_activity
    AuditActivity::CorrectiveAction::Add.from(self)
  end

  def related_file_validation
    if related_file.nil?
      errors.add(:related_file, "- please indicate whether or not there are related files.")
    end
    if related_file == "Yes" && documents.attachments.empty?
      errors.add(:base, :file_missing, message: "Provide a related file or select no")
    end
  end
end
