class LogDbMetricsJob < ApplicationJob
  def perform
    open_investigations_count = Investigation.where(is_closed: false).count
    investigations_count = Investigation.count
    activities_count = Activity.count
    alerts_count = Alert.count

    Sidekiq.logger.info "{
      openInvestigationsCount: #{open_investigations_count},
      investigationsCount: #{investigations_count},
      activitiesCount: #{activities_count},
      alertsCount: #{alerts_count}
      }"
  end
end
