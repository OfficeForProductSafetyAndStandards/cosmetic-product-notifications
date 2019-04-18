class Investigation::Enquiry < Investigation
  include Shared::Web::Concerns::DocumentUploadConcern
  validates :user_title, :description, presence: true, on: :enquiry_details

  validate_upload_document :attachment, [:file], :enquiry_details

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

private

  def create_audit_activity_for_case
    AuditActivity::Investigation::AddEnquiry.from(self)
  end
end
