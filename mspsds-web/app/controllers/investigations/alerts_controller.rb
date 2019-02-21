class Investigations::AlertsController < ApplicationController
  include Wicked::Wizard

  steps :about_alerts, :compose, :confirmation

  before_action :set_investigation

  def new
    redirect_to wizard_path(steps.first)
  end

  def show
    p params
    render_wizard
  end

  def update
    # if records_valid?
      redirect_to next_wizard_path
    # else
    #   render_wizard
    # end
  end

  private

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end
end
