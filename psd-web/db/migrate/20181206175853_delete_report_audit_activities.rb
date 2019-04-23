class DeleteReportAuditActivities < ActiveRecord::Migration[5.2]
  def change
    Activity.where(type: "AuditActivity::Report::Add").delete_all
  end
end
