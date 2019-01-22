class Investigation::Question < Investigation
  validates :user_title, presence: true, on: %i[question_details]
  validates :description, presence: true, on: %i[question_details]

  # Elasticsearch index name must be declared in children and parent
  index_name [Rails.env, "investigations"].join("_")

  def self.model_name
    self.superclass.model_name
  end

  def title
    user_title
  end

  def case_type
    "question"
  end

private

  def create_audit_activity_for_case
    AuditActivity::Investigation::AddQuestion.from(self)
  end
end
