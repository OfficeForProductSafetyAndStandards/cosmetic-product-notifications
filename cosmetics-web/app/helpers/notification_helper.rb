module NotificationHelper
  def component_nano_materials_names(component)
    component.nano_materials.map(&:display_name)
  end

  def nano_materials_with_pdf_links(nano_materials)
    nano_materials.map do |nano|
      if (notification = nano.nanomaterial_notification)
        link = nanomaterial_notification_file_link(notification)
        "#{notification.ukn} - #{notification.name}".tap { |out| out << " </br> #{link}" if link.present? }.html_safe
      else
        nano.display_name
      end
    end
  end

  def nanomaterial_notification_file_link(nanomaterial_notification)
    return unless current_user.can_view_nanomaterial_notification_files?
    return unless nanomaterial_notification&.passed_antivirus_check?

    link_to(nanomaterial_notification.file.filename,
            url_for(nanomaterial_notification.file),
            class: "govuk-link govuk-link--no-visited-state",
            target: "_blank",
            rel: "noopener")
  end

  def nano_materials_with_review_period_end_date(nano_materials)
    nano_materials.filter_map do |nano|
      if (n = nano.nanomaterial_notification)
        "#{n.ukn} - #{n.name} - #{display_full_month_date(n.can_be_made_available_on_uk_market_from)}"
      end
    end
  end
end
