module SupportPortal
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    include CacheConcern
    include HttpAuthConcern
    include SecondaryAuthenticationConcern
    include SentryConfigurationConcern

    protect_from_forgery with: :exception
    before_action :prepare_logger_data
    before_action :authenticate_user!
    before_action :ensure_secondary_authentication
    before_action :require_secondary_authentication
    before_action :set_sentry_context
    before_action :set_cache_headers
    before_action :set_service_name
    before_action :set_paper_trail_whodunnit

    add_flash_types :confirmation

    helper_method :current_user

    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    rescue_from "ActiveRecord::RecordNotFound" do |_e|
      redirect_to "/404"
    end

    # Used by Devise
    def self.default_url_options
      Rails.configuration.action_controller.default_url_options
    end

  private

    def prepare_logger_data
      ::RequestStore.store[:logger_request_id] = request.request_id
      cookies[:journey_uuid] ||= { value: request.request_id, secure: Rails.env.production?, httponly: true }
    end

    def current_user
      current_support_user
    end

    def user_signed_in?
      support_user_signed_in?
    end

    def authenticate_user!
      authenticate_support_user!
    end

    def set_service_name
      @service_name = "OSU Support Portal"
    end
  end
end
