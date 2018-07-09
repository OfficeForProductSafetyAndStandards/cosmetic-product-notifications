class ApplicationController < ActionController::Base
  include HttpAuthConcern
  include Pundit
  protect_from_forgery with: :exception

  before_action :set_paper_trail_whodunnit
end
