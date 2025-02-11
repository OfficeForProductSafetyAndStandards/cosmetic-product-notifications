module Pingdom
  class CheckController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :ensure_secondary_authentication
    skip_before_action :require_secondary_authentication

    def pingdom
      respond_to do |format|
        format.xml { render xml: "<pingdom_http_custom_check><status>OK</status></pingdom_http_custom_check>", status: :ok }
        format.any { return redirect_to "/404" }
      end
    end
  end
end
