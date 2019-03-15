module ShadesHelper
  def display_shades(notification)
    if notification.shades.present?
      render "none_or_bullet_list", entities_list: [notification.shades]
    else
      render "none_or_bullet_list", entities_list: notification.components.first.shades
    end
  end
end
