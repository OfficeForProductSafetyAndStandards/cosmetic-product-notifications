class CpnpNotificationImporter
  class DuplicateNotificationError < FileUploadError; end
  class NotificationValidationError < FileUploadError; end
  class DraftNotificationError < StandardError
    def message
      "DraftNotificationError - Draft notification uploaded"
    end
  end

  def initialize(cpnp_parser, responsible_person)
    @cpnp_parser = cpnp_parser
    @responsible_person = responsible_person
  end

  def create!
    raise DraftNotificationError if parsed_a_draft?

    ::Notification.new(parsed_attributes).tap do |notification|
      notification.notification_file_parsed
      notification.save(context: :file_upload)
      check_validation_errors!(notification)
    end
  end

private

  def parsed_a_draft?
    @cpnp_parser.notification_status == "DR"
  end

  def parsed_attributes
    {
      product_name: @cpnp_parser.product_name,
      shades: @cpnp_parser.shades,
      components: @cpnp_parser.components,
      cpnp_reference: @cpnp_parser.cpnp_reference,
      industry_reference: @cpnp_parser.industry_reference,
      cpnp_notification_date: @cpnp_parser.cpnp_notification_date,
      responsible_person: @responsible_person,
      under_three_years: @cpnp_parser.under_three_years,
      still_on_the_market: @cpnp_parser.still_on_the_market,
      components_are_mixed: @cpnp_parser.components_are_mixed,
      ph_min_value: @cpnp_parser.ph_min_value,
      ph_max_value: @cpnp_parser.ph_max_value,
      was_notified_before_eu_exit: (@cpnp_parser.cpnp_notification_date < EU_EXIT_DATE),
    }
  end

  def check_validation_errors!(notification)
    errors = notification.errors.messages
    return if errors.none?

    if errors[:cpnp_reference].include? Notification.duplicate_notification_message
      raise(DuplicateNotificationError,
            "DuplicateNotificationError - A notification for this product already exists" \
            "for this responsible person (CPNP reference no. #{notification.cpnp_reference})")
    else
      raise NotificationValidationError, "NotificationValidationError - #{errors}"
    end
  end
end
