class Investigations::ReportController < Investigations::FlowController
  steps :type, :details

  def update
    load_reporter_and_investigation
    if @reporter.invalid?(step)
      render step
    elsif step == steps.last
      create
      redirect_to confirmation_investigation_path(@investigation)
    else
      redirect_to next_wizard_path
    end
  end
end
