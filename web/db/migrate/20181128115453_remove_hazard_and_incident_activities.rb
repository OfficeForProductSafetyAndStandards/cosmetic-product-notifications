class RemoveHazardAndIncidentActivities < ActiveRecord::Migration[5.2]
  def change
    Activity.where(type: "AuditActivity::Hazard::Add").delete_all
    Activity.where(type: "AuditActivity::Hazard::Update").delete_all
    Activity.where(type: "AuditActivity::Incident::Add").delete_all
  end
end
