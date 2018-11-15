module ActivityHelper
  def activity_attachment_link_text(activity)
    if activity.is_a?(AuditActivity::Hazard::Base)
      "View risk assessment document"
    elsif activity.is_a?(AuditActivity::Document::Base)
      "View document"
    else
      "View attachment"
    end
  end
end
