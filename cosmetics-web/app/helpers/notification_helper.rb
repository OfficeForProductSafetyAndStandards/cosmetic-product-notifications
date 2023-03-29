module NotificationHelper
  def all_component_ingredients(notification)
    notification.components.map { |component| component_ingredients(component) }.compact
  end

  def all_component_frame_formulations(notification)
    notification.components.map { |component| component_frame_formulation(component) }.compact
  end

  def all_component_cmrs(notification)
    notification.components.map { |component| component_cmrs(component) }.compact
  end

  def all_component_nanomaterials(notification)
    notification.components.map { |component| component_nanomaterials(component) }.compact
  end

  def component_ingredients(component)
    if component.formulation_file.attached?
      if component.formulation_file.metadata["safe"]
        ["<a href=\"#{url_for(component.formulation_file)}\">#{component.formulation_file.filename}</a>"]
      end
    elsif component.ingredients.any?
      component.ingredients.pluck(:inci_name, :exact_concentration, :range_concentration, :used_for_multiple_shades).map do |ingredient|
        if ingredient[1]
          # Exact concentration
          "#{ingredient[0]} - #{display_concentration(ingredient[1], used_for_multiple_shades: ingredient[3])}"
        elsif ingredient[2]
          # Range concentration
          "#{ingredient[0]} - #{display_concentration_range(ingredient[2])}"
        else
          # Frame formulation
          ingredient[0]
        end
      end
    end
  end

  def component_frame_formulation(component)
    if component.frame_formulation.present?
      get_frame_formulation_name(component.frame_formulation)
    end
  end

  def component_cmrs(component)
    if component.cmrs.any?
      component.cmrs.map(&:display_name)
    end
  end

  def component_nanomaterials(component)
    if component.nano_materials.any?
      nano_materials_details(component.nano_materials)
    end
  end

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
