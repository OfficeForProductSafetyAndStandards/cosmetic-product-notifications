class AuditActivity::Correspondence::Base < AuditActivity::Base
  belongs_to :correspondence

  private_class_method def self.from(correspondence, investigation, body = nil)
    self.create(
      body: body || self.sanitize_text(correspondence.details),
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: correspondence.overview,
      correspondence: correspondence
    )
  end
end
