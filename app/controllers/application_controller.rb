class ApplicationController < ActionController::Base
  include HttpAuthConcern
  include Pundit
  protect_from_forgery with: :exception
end
