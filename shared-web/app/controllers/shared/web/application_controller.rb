module Shared
  module Web
    class ApplicationController < ActionController::Base
      include ApplicationConcern
    end
  end
end
