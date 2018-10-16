class IncidentsController < ApplicationController
  before_action :set_investigation, only: %i[new create]
  before_action :build_incident, only: %i[new create]
  # GET investigations/1/incidents/new
  def new
  end

  # POST investigations/1/incidents
  def create
    begin
      @incident = @investigation.incidents.create(incident_params)
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      matches = /error on assignment .* to date \((?<culprit>.*) out of range\)/ =~ e.message
      if matches
        component = case culprit
                    when "argument"
                      "day"
                    when "mon"
                      "month"
                    end
        @incident.errors.add(:date, component)
      end
    end
    if @incident.errors.empty? && @incident.save
      redirect_to investigation_url(@investigation), notice: "Incident was successfully recorded."
    else
      render :new
    end
  end

private

  def build_incident
    @incident = @investigation.incidents.build
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def incident_params
    params.require(:incident).permit(
      :type,
      :description,
      :affected_party,
      :location,
      :date
    )
  end
end
