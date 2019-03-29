module NotificationHelper
  def product_imported?(notification)
    if notification.import_country.present? || notification.cpnp_imported_country.present?
      return "Yes"
    end
    if notification.cpnp_reference.present? #TODO COSBETA-165: check if product is pre-brexit
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
end
