class Investigation::Question < Investigation
  validates :user_title, presence: true, on: %i[question_details]
  validates :description, presence: true, on: %i[question_details]

  def self.model_name
    Investigation.model_name
  end

  def title
    user_title
  end
  index_name [Rails.env, "investigations"].join("_")
private
  def create_audit_activity_for_case
    AuditActivity::Investigation::AddQuestion.from(self)
  end
end
