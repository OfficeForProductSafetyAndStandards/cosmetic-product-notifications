class DeleteVersionHistoryJob < ApplicationJob
  def perform
    PaperTrail::Version.where("created_at < ?", 7.years.ago).delete_all
  end
end
