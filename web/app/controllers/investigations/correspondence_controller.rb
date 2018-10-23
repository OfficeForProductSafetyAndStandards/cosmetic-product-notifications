class Investigations::CorrespondenceController < ApplicationController
  include Wicked::Wizard
  steps :surface, :content, :confirmation

  # GET /investigations/report/new
  def new
    session[:investigation_id] = params[:investigation_id]
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /investigations/report
  def create
    update_partial_correspondence
    @investigation.correspondences << @correspondence
    @investigation.save
    redirect_to investigation_path(@investigation)
  end

  # GET /investigations/report
  # GET /investigations/report/step
  def show
    update_partial_correspondence
    @correspondence = Correspondence.new(session[:correspondence])
    render_wizard
  end

  def update
    update_partial_correspondence
    if !@correspondence.valid?(step)
      render step
    else
      create if next_step? :confirmation
      redirect_to next_wizard_path
    end
  end

private

  def correspondence_params
    return {} if !params[:correspondence] || params[:correspondence] == {}
    if params[:correspondence][:correspondent_type] == 'Other'
      params[:correspondence][:correspondent_type] = params[:correspondence][:other_correspondent_type]
    end
    params.require(:correspondence).permit(
      :correspondent_name, :correspondent_type, :contact_method, :phone_number, :email_address, :correspondence_date,
      :overview, :details
    )
  end

  def update_partial_correspondence
    p '========================='
    p session[:investigation_id]
    @investigation = Investigation.find_by(id: session[:investigation_id])
    p @investigation
    session[:correspondence] = (session[:correspondence] || {}).merge(correspondence_params)
    @correspondence = Correspondence.new(session[:correspondence])
    session[:correspondence] = @correspondence.attributes
  end
end
