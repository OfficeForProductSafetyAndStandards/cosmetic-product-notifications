module Shared
  module Web
    class ApplicationController < ActionController::Base
      include AuthenticationConcern
    end
  end
end
