module ShadesHelper
  def display_shades(notification)
    if notification.shades.present?
      render "none_or_bullet_list", entities_list: [notification.shades]
    elsif notification.components&.first&.shades.present?
      render "none_or_bullet_list", entities_list: notification.components&.first&.shades
    else
      "None"
    end
  end
end
