class AuditActivity::Correspondence::Base < AuditActivity::Base
  belongs_to :correspondence

  private_class_method def self.from(correspondence, investigation)
    self.create(
      body: correspondence.details,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: correspondence.overview,
      correspondence: correspondence
    )
  end
end
