class IncidentsController < ApplicationController
  # GET investigations/1/incidents/new
  def new
    @investigation = Investigation.find(params[:investigation_id])
    @incident = @investigation.incidents.build
  end

  # POST investigations/1/incidents
  def create
    @investigation = Investigation.find(params[:investigation_id])
    @incident = @investigation.incidents.create(incident_params)
    if @incident.save
      redirect_to investigation_url(@investigation), notice: "Incident was successfully recorded."
    else
      render :new
    end
  end

  private

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
