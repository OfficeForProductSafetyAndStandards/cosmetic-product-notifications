class Investigation::Project < Investigation
  validates :user_title, presence: true
  validates :description, presence: true

  def self.model_name
    Investigation.model_name
  end

  def title
    user_title
  end
  index_name [Rails.env, "investigations"].join("_")
private
  def create_audit_activity_for_case
    AuditActivity::Investigation::AddProject.from(self)
  end
end
