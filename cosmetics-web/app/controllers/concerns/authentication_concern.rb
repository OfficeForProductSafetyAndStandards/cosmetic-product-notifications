module AuthenticationConcern
  extend ActiveSupport::Concern

  include Pundit

  include ::LoginHelper

  def pundit_user
    current_submit_user
  end
end
