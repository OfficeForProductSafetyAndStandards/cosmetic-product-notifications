module Shared
  module Web
    class ApplicationController < ActionController::Base
      include Shared::Web::Concerns::AuthenticationConcern
    end
  end
end
