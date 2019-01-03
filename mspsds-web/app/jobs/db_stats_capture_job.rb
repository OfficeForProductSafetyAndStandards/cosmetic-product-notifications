class DbStatsCaptureJob < ApplicationJob
  def perform
    PgHero.capture_query_stats
    PgHero.capture_space_stats
  end
end
