class LogDbMetricsJob < ApplicationJob
  def perform
    complete_notifications_count = Notification.where(state: "notification_complete").count
    responsible_persons_count = ResponsiblePerson.count
    users_per_responsible_person = ResponsiblePersonUser.group(:responsible_person_id)
      .count.values.sort.each_with_object(Hash.new(0)) { |e, h| h[e] += 1; }

    Sidekiq.logger.info "{
      completeNotifications: #{complete_notifications_count},
      responsiblePersons: #{responsible_persons_count},
      usersPerResponsiblePerson: #{users_per_responsible_person}
      }"
  end
end
