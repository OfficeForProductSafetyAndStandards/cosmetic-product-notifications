class Investigations::AlertsController < ApplicationController
  include Wicked::Wizard
  include Pundit
  include ActionView::Helpers::NumberHelper

  steps :about_alerts, :compose, :preview

  before_action :set_investigation
  before_action :set_default_field_values, only: %i[show update], if: -> { step == :compose }
  before_action :set_alert, only: %i[show update], if: -> { %i[compose preview].include? step }
  before_action :store_alert, only: :update, if: -> { step == :compose }
  before_action :set_user_count, only: %i[show update create], if: -> { step == :preview }
  before_action :get_preview, only: :show, if: -> { step == :preview }

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
      render_wizard
    end
  end

  def create
    @alert.save
    redirect_to investigation_path(@investigation), flash: { success: "Email alert sent to #{@user_count} users" }
  end

private

  def clear_session
    session.delete(:alert)
  end

  def alert_valid?
    @alert.valid?
    if @alert.description == @default_description
      @alert.errors.add(:description, "Enter alert content")
    end
    if @alert.summary == @default_summary
      @alert.errors.add(:summary, "Enter an alert summary")
    end
    @alert.errors.none?
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize_investigation
  end

  def authorize_investigation
    authorize @investigation, :user_allowed_to_raise_alert?
    authorize @investigation, :investigation_restricted? if %i[compose preview].include? step
  end

  def set_alert
    @alert = Alert.new alert_params.merge(
      investigation_id: @investigation.id,
      source: UserSource.new(user: User.current)
    )
  end

  def set_default_field_values
    @default_summary = "Product safety alert: "
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

  def set_user_count
    @user_count = number_with_delimiter(User.all.length, delimiter: ',')
  end

  def get_preview
    @preview = NotificationsClient.instance.generate_template_preview(
      NotifyMailer::TEMPLATES[:alert],
        personalisation: {
          name: "<Name>",
          email_text: @alert.description,
          subject_text: @alert.summary
        }
    )
  end
end
