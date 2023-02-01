module ResponsiblePersonQueryConcern
  extend ActiveSupport::Concern

  def responsible_persons_by_notified_ingredient(ingredient_inci_name, sort_by:, page:, per_page:)
    ResponsiblePerson
      .joins(notifications: { components: :ingredients })
      .where(notifications: { components: { ingredients: { inci_name: ingredient_inci_name } } })
      .select("responsible_persons.id, responsible_persons.name, count(notifications.id) AS total_notifications")
      .group("responsible_persons.id, responsible_persons.name")
      .order(sort_by)
      .page(page).per(per_page)
  end

  def notifications_by_notified_ingredient(ingredient_inci_name, responsible_person:, sort_by:, page:, per_page:)
    Notification
      .joins(:responsible_person, components: :ingredients)
      .where(responsible_person:, components: { ingredients: { inci_name: ingredient_inci_name } })
      .select("notifications.product_name, notifications.reference_number, notifications.cpnp_reference, notifications.notification_complete_at, notifications.responsible_person_id")
      .order(sort_by)
      .page(page).per(per_page)
  end
end
