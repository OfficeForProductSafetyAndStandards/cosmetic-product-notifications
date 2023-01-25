class LogDbMetricsJob < ApplicationJob
  def perform
    stats = {
      complete_notifications_count: Notification.where(state: "notification_complete").count,
      complete_notifications_count_last_hour: Notification.where(state: "notification_complete").where("created_at >= ?", 1.hour.ago).count,
      incomplete_notifications_count: Notification.where.not(state: "notification_complete").count,
      incomplete_notifications_count_last_hour: Notification.where("created_at >= ?", 1.hour.ago).where.not(state: "notification_complete").count,
      responsible_persons_count: ResponsiblePerson.count,
      submit_users_count: SubmitUser.count,
      responsible_persons_count_last_hour: ResponsiblePerson.where("created_at >= ?", 1.hour.ago).count,
      submit_users_count_last_hour: SubmitUser.where("created_at >= ?", 1.hour.ago).count,
      complete_notifications_count_manual: Notification.where(state: "notification_complete").where("cpnp_reference IS NULL").count,
      complete_notifications_count_zip: Notification.where(state: "notification_complete").where("cpnp_reference IS NOT NULL").count,
      products_notified_after_eu_exit: Notification.completed.where(was_notified_before_eu_exit: false).count,
      products_notified_before_eu_exit: Notification.completed.where(was_notified_before_eu_exit: true).count,
      business_rp_count: ResponsiblePerson.where(account_type: "business").count,
      individual_rp_count: ResponsiblePerson.where(account_type: "individual").count,
      nanomaterials_notified: NanomaterialNotification.where.not(submitted_at: nil).count,
      notifications_with_nanomaterials: Notification.completed.joins(:nano_materials).distinct.count,
    }

    Sidekiq.logger.info "CosmeticsStatistics #{stats.to_a.map { |x| x.join('=') }.join(' ')}"

    users_per_responsible_person = ResponsiblePersonUser.group(:responsible_person_id)
      .count.values.sort.each_with_object(Hash.new(0)) { |e, h| h[e] += 1 }

    Sidekiq.logger.info "usersPerResponsiblePerson: #{users_per_responsible_person}"
  end
end
