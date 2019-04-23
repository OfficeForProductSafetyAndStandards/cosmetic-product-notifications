module NotificationHelper
  def product_imported?(notification)
    if notification.import_country == "country:GB" || notification.cpnp_imported_country == "country:GB"
      return "No"
    end
    if notification.import_country.present? || notification.cpnp_imported_country.present?
      return "Yes"
    end
    if notification.cpnp_reference.present? && notification.notified_pre_eu_exit?
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
