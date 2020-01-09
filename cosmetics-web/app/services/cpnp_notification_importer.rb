class CpnpNotificationImporter
  class DuplicateNotificationError < FileUploadError; end
  class NotificationValidationError < FileUploadError; end
  class DraftNotificationError < StandardError; end
  class CpnpFileNotifiedPostBrexitError < StandardError; end

  def initialize(cpnp_parser, responsible_person)
    @cpnp_parser = cpnp_parser
    @responsible_person = responsible_person
  end

  def create!
    if @cpnp_parser.notification_status == "DR"
      raise DraftNotificationError, "DraftNotificationError - Draft notification uploaded"
    elsif @cpnp_parser.cpnp_notification_date >= EU_EXIT_DATE
      raise CpnpFileNotifiedPostBrexitError, "Product was notified to CPNP post-Brexit, which is not currently supported"
    else
      notification = ::Notification.new(product_name: @cpnp_parser.product_name,
                                        shades: @cpnp_parser.shades,
                                        components: @cpnp_parser.components,
                                        cpnp_reference: @cpnp_parser.cpnp_reference,
                                        industry_reference: @cpnp_parser.industry_reference,
                                        cpnp_is_imported: @cpnp_parser.is_imported,
                                        cpnp_imported_country: @cpnp_parser.imported_country,
                                        cpnp_notification_date: @cpnp_parser.cpnp_notification_date,
                                        responsible_person: @responsible_person,
                                        under_three_years: @cpnp_parser.under_three_years,
                                        still_on_the_market: @cpnp_parser.still_on_the_market,
                                        components_are_mixed: @cpnp_parser.components_are_mixed,
                                        ph_min_value: @cpnp_parser.ph_min_value,
                                        ph_max_value: @cpnp_parser.ph_max_value)

      notification.notification_file_parsed
      notification.save(context: :file_upload)
      if notification.errors.messages.present?
        if notification.errors.messages[:cpnp_reference].include? Notification.duplicate_notification_message
          raise DuplicateNotificationError, "DuplicateNotificationError - A notification for this product already
            exists for this responsible person (CPNP reference no. #{notification.cpnp_reference})"
        else
          raise NotificationValidationError, "NotificationValidationError - #{notification.errors.messages}"
        end
      end
      notification
    end
  end
end
