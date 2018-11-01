class AuditActivity::Business < AuditActivity
  belongs_to :business

  private_class_method def self.from(business, investigation)
    relationship = investigation.investigation_businesses.find_by(business_id: business.id).relationship
    self.create(
        body: "Role: **#{relationship.titleize}**",
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: business.company_name,
        business: business
    )
  end
end
