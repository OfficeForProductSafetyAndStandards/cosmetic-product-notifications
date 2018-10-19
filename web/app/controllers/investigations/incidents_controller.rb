class Investigations::IncidentsController < ApplicationController
  include Wicked::Wizard
  steps :details, :confirmation

  before_action :set_investigation
  before_action :build_incident_from_params, only: %i[update]
  before_action :store_incident, only: %i[update]
  before_action :restore_incident, only: %i[show create]

  # GET investigations/1/incidents/new
  def new;
    session[:incident] = {}
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET investigations/1/incidents/step
  def show
    render_wizard
  end

  # PUT investigations/1/incidents/step
  def update
    if !@incident.valid?(step)
      render step
    else
      redirect_to next_wizard_path if step != steps.last
      create if step == steps.last
    end
  end

  # POST investigations/1/incidents
  def create
    if @incident.save
      redirect_to investigation_url(@investigation), notice: "Incident was successfully recorded."
    else
      render step
    end
  end

private

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def build_incident_from_params
    @incident = if params.include? :incident
                  @investigation.incidents.build(incident_params)
                else
                  @investigation.incidents.build
                end
  end

  def store_incident
    session[:incident] = @incident.attributes
  end

  def restore_incident
    @incident = @investigation.incidents.build(session[:incident])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def incident_params
    params.require(:incident).permit(:incident_type,
                                     :description,
                                     :affected_party,
                                     :location,
                                     :day,
                                     :month,
                                     :year)
  end
end
