module NotificationHelper
  def product_imported?(notification)
    notification.import_country.present? || notification.cpnp_reference.present?
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

  def product_shades(notification)
    notification.components.first&.shades&.join(", ") || notification.shades || "N/A"
  end
end
