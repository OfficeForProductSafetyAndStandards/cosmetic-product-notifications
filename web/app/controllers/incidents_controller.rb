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
      @incident.errors.add(:date, "Enter a real incident date")
      if /error on assignment .* to date \((?<culprit>.*) out of range\)/ =~ e.message
        component = case culprit
                    when "argument"
                      :day
                    when "mon"
                      :month
                    end
        @incident.errors.add(component)
      end
    rescue MspsdsException::IncompleteDateParsedException => e
      e.missing_fields.each do |component|
        @incident.errors.add(:date, "Enter date of incident and include a day, month and year")
        @incident.errors.add(component)
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
    parsed_params = params.require(:incident).permit(
      :type,
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
end
