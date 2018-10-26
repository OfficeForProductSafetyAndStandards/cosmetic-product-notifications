class AddBusinessAuditActivity < BusinessAuditActivity
  def title
    business.company_name
  end

  def subtitle_slug
    "Business added"
  end
end
