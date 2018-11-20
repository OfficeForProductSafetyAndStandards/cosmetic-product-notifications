class AuditActivity::Correspondence::AddPhoneCall < AuditActivity::Correspondence::Base
  has_one_attached :file

  def self.from(correspondence, investigation)
    activity = super(correspondence, investigation, self.build_body(correspondence))
    if (file = correspondence.find_attachment_by_category "file")
      activity.file.attach file.blob
    end
  end

  def self.build_body correspondence
    output = ""
    output += self.build_correspondent_details correspondence
    output += "Date: **#{correspondence.correspondence_date}**<br>" if correspondence.correspondence_date.present?
    output += self.build_file_body correspondence
    output += "<br>#{correspondence.details}"
    output
  end

  def self.build_correspondent_details correspondence
    return "" unless correspondence.correspondent_name || correspondence.phone_number

    output = "Call with: "
    output += "**#{correspondence.correspondent_name}** " if correspondence.correspondent_name.present?
    output += self.build_phone_number correspondence if correspondence.phone_number.present?
    output
  end

  def self.build_phone_number correspondence
    output = ""
    output += '(' if correspondence.correspondent_name.present?
    output += correspondence.phone_number
    output += ')' if correspondence.correspondent_name.present?
    output + "<br>"
  end

  def self.build_file_body correspondence
    file = correspondence.find_attachment_by_category "file"
    file ? "Attached: #{file.filename}<br>" : ""
  end

  def attachments
    file.attached? ? { file: "transcript" } : {}
  end

  def subtitle_slug
    "Phonecall"
  end
end
