class Investigations::IncidentsController < ApplicationController
  include Wicked::Wizard
  steps :details, :confirmation

  before_action :set_investigation, only: %i[new create show update]
  before_action :build_incident, only: %i[new create update]

  # GET investigations/1/incidents/new
  def new;
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET investigations/1/incidents/step
  def show
    session[:incident] = {} if step == steps.first
    @incident = @investigation.incidents.build(session[:incident])
    render_wizard
  end

  def update
    session[:incident] = @incident.attributes
    if !@incident.valid?(step)
      render step
    else
      redirect_to next_wizard_path if step != steps.last
      create if step == steps.last
    end
  end

  # POST investigations/1/incidents
  def create
    @incident = @investigation.incidents.build(session[:incident])
    if @incident.errors.empty? && @incident.save
      redirect_to investigation_url(@investigation), notice: "Incident was successfully recorded."
    else
      set_intermediate_params
      render step
    end
  end

private

  def build_incident
    if params.include? :incident
      @incident = @investigation.incidents.build(incident_params)
    else
      @incident = @investigation.incidents.build
    end
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
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
