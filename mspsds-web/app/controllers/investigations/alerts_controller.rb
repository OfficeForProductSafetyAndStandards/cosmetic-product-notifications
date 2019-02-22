class Investigations::AlertsController < ApplicationController
  include Wicked::Wizard

  steps :about_alerts, :compose, :preview

  before_action :set_investigation
  before_action :set_alert, only: %i[show update], if: -> { %i[compose preview].include? step }
  before_action :store_alert, only: :update, if: -> { step == :compose }
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

  def set_alert
    @alert = Alert.new alert_params
    # @email_subject = compose_step_params[:email_subject] || session[:email_subject]
    # @email_body = compose_step_params[:email_body] || session[:email_body]
  end

  def store_alert
    session[:alert] = @alert
  end

  def alert_params
    return {} unless params.has_key? :alert

    params.require(:alert).permit(:summary, :description)
  end
end
