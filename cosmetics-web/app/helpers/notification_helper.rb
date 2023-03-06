module NotificationHelper
  def nano_materials_details(nano_materials)
    nano_materials.map do |nano|
      if (notification = nano.nanomaterial_notification)
        render("notifications/nanomaterial_notification_details", nanomaterial_notification: notification)
      else
        nano.display_name
      end
    end
  end

  def nano_materials_with_review_period_end_date(nano_materials)
    nano_materials.filter_map do |nano|
      if (n = nano.nanomaterial_notification)
        "#{n.ukn} - #{n.name} - #{display_full_month_date(n.can_be_made_available_on_uk_market_from)}"
      end
    end
  end
end
