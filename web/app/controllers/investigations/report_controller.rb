class Investigations::ReportController < ApplicationController
  include InvestigationFlowHelper
  include Wicked::Wizard
  steps :type, :details, :confirmation

  def update
    load_reporter_and_investigation
    if !@reporter.valid?(step)
      render step
    else
      create if next_step? :confirmation
      redirect_to next_wizard_path
    end
  end

private

  def default_investigation
    Investigation.new(is_case: true)
  end
end
