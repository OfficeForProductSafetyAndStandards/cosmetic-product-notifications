class Investigations::ReportController < ApplicationController
  include Wicked::Wizard
  steps :type, :details

  def show
    if step == steps.first
      session[:reporter] = {}
    end
    @reporter = Reporter.new(session[:reporter])
    render_wizard
  end

  def update
    session[:reporter] = session[:reporter].merge(reporter_params)
    @reporter = Reporter.new(session[:reporter].merge({step: step}))
    @investigation = Investigation.new
    @investigation.reporter = @reporter
    @investigation.source = UserSource.new(user: current_user)
    if !@reporter.valid?
      render step
    elsif step != steps.last
      session[:reporter] = @reporter.attributes
      redirect_to next_wizard_path
    else
      @investigation.save
      redirect_to investigation_path(@investigation)
    end
  end

  private

  def reporter_params
    if params[:reporter][:reporter_type] == 'Other'
      params[:reporter][:reporter_type] = params[:reporter][:other_reporter]
    end
    params.require(:reporter).permit(
      :name, :phone_number, :email_address, :reporter_type, :other_details
    )
  end

end
