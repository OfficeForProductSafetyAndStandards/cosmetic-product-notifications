class Investigations::HazardsController < ApplicationController
  include FileConcern
  include HazardsHelper
  before_action :load_relevant_objects

  def risk_level;
    initialize_file_attachment
  end

  def update_risk_level
    update_risk_assessment
    @hazard.save
    redirect_to @investigation, notice: 'Risk was successfully updated.'
  end

private

  def set_hazard_data(investigation)
    @hazard = investigation.hazard
    @hazard.assign_attributes(hazard_params || {})
  end

  def create_hazard_audit_activity
    AuditActivity::Hazard::Update.from(@hazard, @investigation)
  end
end
