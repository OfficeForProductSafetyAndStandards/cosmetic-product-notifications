class LogDbMetricsJob < ApplicationJob
    def perform
      open_investigations_count = Investigation.where(is_closed: false).count
      investigations_count = Investestigation.count
  
      Sidekiq.logger.info "{
        openInvestigationsCount: #{open_investigations_count},
        investigationsCount: #{investigations_count}
        }"
    end
end