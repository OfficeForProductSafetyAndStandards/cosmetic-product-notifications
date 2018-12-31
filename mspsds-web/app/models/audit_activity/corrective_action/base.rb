class AuditActivity::CorrectiveAction::Base < AuditActivity::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  belongs_to :business
  belongs_to :product

  private_class_method def self.from(corrective_action)
    activity = self.create(
      title: corrective_action.summary,
      body: self.build_body(self.sanitize_object(corrective_action)),
      source: UserSource.new(user: current_user),
      investigation: corrective_action.investigation,
      business: corrective_action.business,
      product: corrective_action.product
    )
    activity.attach_blob corrective_action.documents.first.blob if corrective_action.documents.attached?
  end

  def self.build_body(corrective_action)
    body = ""
    body += "Product: **#{corrective_action.product.name}**<br>" if corrective_action.product.present?
    body += "Legislation: **#{corrective_action.legislation}**<br>" if corrective_action.legislation.present?
    body += "Business responsible: **#{corrective_action.business.company_name}**<br>" if corrective_action.business.present?
    body += "Date decided: **#{corrective_action.date_decided.strftime('%d/%m/%Y')}**<br>" if corrective_action.date_decided.present?
    body += "Attached: **#{corrective_action.documents.first.escaped_filename}**<br>" if corrective_action.documents.attached?
    body += "<br>#{corrective_action.details}" if corrective_action.details.present?
    body
  end
end
