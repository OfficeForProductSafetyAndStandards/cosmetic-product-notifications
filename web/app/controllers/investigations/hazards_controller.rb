class Investigations::HazardsController < ApplicationController
  include FileConcern
  set_attachment_names :file
  set_file_params_key :hazard

  include HazardsHelper
  before_action :load_relevant_objects

  def risk_level
    initialize_file_attachments
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
end
