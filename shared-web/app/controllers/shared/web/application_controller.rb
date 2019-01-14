module Shared
  module Web
    class ApplicationController < ActionController::Base
      include Shared::Web::Concerns::AuthenticationConcern

      protect_from_forgery with: :exception
      before_action :authenticate_user!
    end
  end
end
