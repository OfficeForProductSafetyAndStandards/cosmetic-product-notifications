module AuthenticationConcern
  extend ActiveSupport::Concern

  include Pundit::Authorization

  def pundit_user
    current_submit_user || current_search_user
  end
end
