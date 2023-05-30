module SupportPortal
  class ApplicationController < ActionController::Base
    before_action :set_service_name

    def current_user
      # TODO(ruben): Remove this once Devise has been included
    end
    helper_method :current_user

  private

    def set_service_name
      @service_name = "OSU Support Portal"
    end
  end
end
