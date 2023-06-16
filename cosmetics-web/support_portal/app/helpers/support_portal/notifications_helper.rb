module SupportPortal
  module NotificationsHelper
    def status_checkboxes
      [
        OpenStruct.new(id: "live", name: "Live"),
        OpenStruct.new(id: "archived", name: "Archived"),
        OpenStruct.new(id: "deleted", name: "Deleted"),
      ]
    end

    def sort_order_icon(order)
      case order
      when "desc"
        "&#x25bc;"
      else
        "&#x25b2;"
      end
    end

    def product_name_sort_order_link(current_sort_order)
      sort_order = current_sort_order.nil? || current_sort_order == "asc" ? "desc" : "asc"
      query_string = { notification_search: request.params[:notification_search].except(:notification_complete_at_sort_order).merge(product_name_sort_order: sort_order) }.to_query
      "?#{query_string}"
    end

    def notification_complete_at_sort_order_link(current_sort_order)
      sort_order = current_sort_order.nil? || current_sort_order == "asc" ? "desc" : "asc"
      query_string = { notification_search: request.params[:notification_search].except(:product_name_sort_order).merge(notification_complete_at_sort_order: sort_order) }.to_query
      "?#{query_string}"
    end

    def status_type(state)
      { "notification_complete" => "Live", "archived" => "Archived", "deleted" => "Deleted" }[state]
    end

    def notification_ukcp_reference_number
      "UKCP-#{@notification.reference_number}"
    end

    def notification_uk_notified_date
      @notification.notification_complete_at.strftime("#{@notification.notification_complete_at.day.ordinalize} %B %Y")
    end

    def notification_children_under_three
      @notification.under_three_years ? "Yes" : "No"
    end

    def notification_number_of_items
      @notification.is_a?(::DeletedNotification) ? @notification.notification.components.length : @notification.components.length
    end

    def notification_shades
      return "None" if @notification.shades.blank?

      shades = @notification.shades.is_a?(String) ? @notification.shades.split(" ") : @notification.shades
      shades.join(", ")
    end

    def notification_labels
      links = []

      image_uploads = if @notification.is_a?(::DeletedNotification)
                        @notification.notification.image_uploads
                      else
                        @notification.image_uploads
                      end

      image_uploads.each do |image|
        links << "<a href=\"#{Rails.application.routes.url_helpers.rails_blob_path(image.file, only_path: true)}\" class=\"govuk-link govuk-link--no-visited-state\" target=\"_blank\" rel=\"noreferrer noopener\">#{image.filename}</a>" if image.passed_antivirus_check?
      end

      links.join(", ").html_safe
    end

    def notification_mixed
      @notification.components_are_mixed ? "Yes" : "No"
    end

    def responsible_person
      @notification.is_a?(::DeletedNotification) ? @notification.notification.responsible_person : @notification.responsible_person
    end

    def contact_persons
      @notification.is_a?(::DeletedNotification) ? @notification.notification.responsible_person.contact_persons : @notification.responsible_person.contact_persons
    end

    def history_event_time(record)
      Time.zone.parse(record.object["updated_at"]).strftime("%d/%m/%Y %H:%M")
    end

    def history_event_name(record)
      case record.event
      when "archive"
        "<strong>Archived:</strong> #{archive_history_reason(record)}"
      when "unarchive"
        "<strong>Unarchived</strong>"
      when "delete"
        "<strong>Deleted</strong>"
      when "undelete"
        "<strong>Recovered</strong>"
      end
    end

  private

    ARCHIVE_REASON = {
      product_no_longer_available_on_the_market: "Product no longer available on the market",
      product_no_longer_manufactured: "Product no longer manufactured",
      change_of_responsible_person: "Change of Responsible Person",
      change_of_manufacturer: "Change of manufacturer",
      significant_change_to_the_formulation: "Significant change to the formulation",
      product_notified_but_did_not_get_placed_on_the_market: "Product notified but did not get placed on the market",
      error_in_the_notification: "Error in the notification",
    }.freeze

    def archive_history_reason(record)
      ARCHIVE_REASON[record.object["archive_reason"]&.to_sym]
    end
  end
end
