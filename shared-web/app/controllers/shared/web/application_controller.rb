module Shared
  module Web
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception
      before_action :authenticate_user!

      helper_method :current_user, :user_signed_in?
    end
  end
end
