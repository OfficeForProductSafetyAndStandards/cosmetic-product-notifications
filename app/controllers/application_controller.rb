class ApplicationController < ActionController::Base
  include HttpAuthConcern
  protect_from_forgery with: :exception
end
