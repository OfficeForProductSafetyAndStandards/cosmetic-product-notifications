class LogDbMetricsJob < ApplicationJob
  def perform
    Sidekiq.logger.info "{
      completeNotifications: #{Notification.where(state: 'notification_complete').count},
      responsiblePersons: #{ResponsiblePerson.count},
      usersPerResponsiblePerson: #{ResponsiblePersonUser.group(:responsible_person_id).count.values.sort.inject(
        Hash.new(0)
) { |h, e| h[e] += 1; h }}
      }"
  end
end
