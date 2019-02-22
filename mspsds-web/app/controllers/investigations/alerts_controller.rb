class Investigations::AlertsController < ApplicationController
  include Wicked::Wizard

  steps :about_alerts, :compose, :preview

  before_action :set_investigation
  before_action :set_default_description, only: %i[show update], if: -> { step == :compose }
  before_action :set_alert, only: %i[show update], if: -> { %i[compose preview].include? step }
  before_action :store_alert, only: :update, if: -> { step == :compose }

  def new
    clear_session
    redirect_to wizard_path(steps.first)
  end

  def show
    render_wizard
  end

  def update
    if alert_valid?
      return create if step == steps.last
      redirect_to next_wizard_path
    else
      @alert.errors.each {|e| p e}
      render_wizard
    end
  end

  def create
    @alert.source = UserSource.new(user: current_user)
    @alert.save
    redirect_to investigation_path(@investigation), notice: "Alert sent XXXX"
  end

private

  def clear_session
    session.delete(:alert)
  end

  def alert_valid?
    @alert.valid?
    if @alert.description.blank? || @alert.description == @default_description
      @alert.errors.add(:description, "Please provide email content XXXXXX")
    end
    @alert.errors.none?
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end

  def set_alert
    @alert = Alert.new alert_params.merge(investigation_id: @investigation.id)
  end

  def set_default_description
    @default_description = "\r\n\r\n\r\nMore details can be found on the case page: #{investigation_url @investigation}"
  end

  def store_alert
    session[:alert] = @alert.attributes
  end

  def alert_params
    alert_session_params.merge(alert_request_params).symbolize_keys
  end

  def alert_session_params
    session[:alert] || {}
  end

  def alert_request_params
    return {} unless params.has_key? :alert

    params.require(:alert).permit(:summary, :description)
  end
end
