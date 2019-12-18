class CpnpNotificationExporter
  attr_reader :notification

  def initialize(cpnp_parser)
    @cpnp_parser
  end

  def create!
    if cpnp_export_info.notification_status == "DR"
      raise DraftNotificationError, "DraftNotificationError - Draft notification uploaded"
    elsif cpnp_export_info.cpnp_notification_date >= EU_EXIT_DATE
      raise CpnpFileNotifiedPostBrexitError, "Product was notified to CPNP post-Brexit, which is not currently supported"
    else
      @notification = ::Notification.new(product_name: cpnp_export_info.product_name,
                                        shades: cpnp_export_info.shades,
                                        components: cpnp_export_info.components,
                                        cpnp_reference: cpnp_export_info.cpnp_reference,
                                        industry_reference: cpnp_export_info.industry_reference,
                                        cpnp_is_imported: cpnp_export_info.is_imported,
                                        cpnp_imported_country: cpnp_export_info.imported_country,
                                        cpnp_notification_date: cpnp_export_info.cpnp_notification_date,
                                        responsible_person: @notification_file.responsible_person,
                                        under_three_years: cpnp_export_info.under_three_years,
                                        still_on_the_market: cpnp_export_info.still_on_the_market,
                                        components_are_mixed: cpnp_export_info.components_are_mixed,
                                        ph_min_value: cpnp_export_info.ph_min_value,
                                        ph_max_value: cpnp_export_info.ph_max_value)
      @notification.notification_file_parsed
      @notification.save(context: :file_upload)
    end
  end
end
