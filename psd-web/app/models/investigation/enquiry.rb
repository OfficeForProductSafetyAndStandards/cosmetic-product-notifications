class Investigation::Enquiry < Investigation
  include Shared::Web::Concerns::DateConcern
  validates :user_title, :description, presence: true, on: :enquiry_details
  validate :date_cannot_be_in_the_future, :date_cannot_be_blank, on: :about_enquiry

  date_attribute :date_received, required: false

  # Elasticsearch index name must be declared in children and parent
  index_name [Rails.env, "investigations"].join("_")

  def self.model_name
    self.superclass.model_name
  end

  def title
    user_title
  end

  def case_type
    "enquiry"
  end

  def date_cannot_be_blank
    if date_received.blank? && errors.messages.blank?
      errors.add(:date_received, "Date received can't be blank")
    end
  end

  def date_cannot_be_in_the_future
    if date_received.present? && date_received > Time.zone.today
      errors.add(:date_received, 'Date received must be today or in the past')
    end
  end

private

  def create_audit_activity_for_case
    AuditActivity::Investigation::AddEnquiry.from(self)
  end
end
