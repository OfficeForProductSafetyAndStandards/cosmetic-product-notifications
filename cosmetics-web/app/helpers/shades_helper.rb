module ShadesHelper
  def display_shades(notification)
    if notification.shades.present?
      render("none_or_bullet_list",
             entities_list: [notification.shades],
             list_item_classes: "",
             list_classes: "")
    else
      shades = notification.components.pluck(:shades).flatten.compact.uniq
      if shades.any?
        render("none_or_bullet_list", entities_list: shades, list_item_classes: "", list_classes: "")
      else
        "None"
      end
    end
  end
end
