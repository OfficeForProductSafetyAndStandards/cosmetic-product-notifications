module AdditionalInformationHelper
  def link_text(notification)
    if notification.formulation_required? && notification.images_required?
      "Add formulation document and product image to finish the notification"
    elsif notification.formulation_required?
      "Add formulation document to finish the notification"
    else
      "Add product image to finish the notification"
    end
  end
end
