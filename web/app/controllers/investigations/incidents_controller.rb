class Investigations::IncidentsController < ApplicationController
  include Wicked::Wizard
  steps :details, :confirmation

  before_action :set_investigation, only: %i[new create show]
  before_action :build_incident, only: %i[new create show]

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
    set_investigation
    build_incident
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
    begin
      @incident = @investigation.incidents.build
      if params.include? :incident
        @incident = @investigation.incidents.build(incident_params)
      end
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      @incident.errors.add(:date, "Enter a real incident date")
      if /error on assignment .* to date \((?<culprit>.*) out of range\)/ =~ e.message
        component = case culprit
                    when "argument"
                      :day
                    when "mday"
                      :day
                    when "mon"
                      :month
                    end
        @incident.errors.add(component)
      end
    rescue MspsdsException::IncompleteDateParsedException => e
      e.missing_fields.each do |missing_component|
        @incident.errors.add(:date, "Enter date of incident and include a day, month and year")
        @incident.errors.add(missing_component)
      end
    end
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def incident_params
    parsed_params = params.require(:incident).permit(
      :incident_type,
      :description,
      :affected_party,
      :location,
      :date
    )
    missing_date_components = {
      day: parsed_params[:'date(3i)'],
      month: parsed_params[:'date(2i)'],
      year: parsed_params[:'date(1i)']
    }.select { |_, value| value.blank? }
    if (1..2) === missing_date_components.length # Date has some components entered, but not all
      raise MspsdsException::IncompleteDateParsedException.new missing_date_components.keys
    end

    parsed_params
  end

  # The odd date-handling means that the incident creation can fail pre-validation.
  # This leaves the model unpopulated, clearing the form.
  # Calling this method ensures that all of the entered values remain filled in in the form
  def set_intermediate_params
    params_without_date = params.require(:incident).permit(
      :incident_type,
      :description,
      :affected_party,
      :location,
    )
    @incident.assign_attributes(params_without_date)
    date_components = params.require(:incident).permit(
      :'date(3i)',
      :'date(2i)',
      :'date(1i)'
    )
    @incident.day = date_components[:'date(3i)']
    @incident.month = date_components[:'date(2i)']
    @incident.year = date_components[:'date(1i)']
  end
end
