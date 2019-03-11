module NotificationHelper
  def product_imported?(notification)
    if notification.import_country.present? || notification.cpnp_imported_country.present?
      return "Yes"
    end
    if notification.cpnp_reference.present? #TODO: check if product is pre-brexit
      return "Manufactured in EU before Brexit"
    end
    "No"
  end

  def product_import_country(notification)
    return nil unless product_imported?(notification)

    if notification.import_country.present?
      country_from_code(notification.import_country)
    elsif notification.cpnp_imported_country.present?
      country_from_code(notification.cpnp_imported_country)
    else
      "EU (before Brexit)"
    end
  end

  def non_or_bullet_list_html(entities_list)
    if entities_list.blank?
      return "None"
    elsif entities_list.length == 1
      return entities_list.first
    end

    bullet_list = "<ul class='govuk-list govuk-list--bullet'>"
    entities_list.each do |entity|
      bullet_list += "<li>#{entity}</li>"
    end
    bullet_list + "</ul>"
  end
end
