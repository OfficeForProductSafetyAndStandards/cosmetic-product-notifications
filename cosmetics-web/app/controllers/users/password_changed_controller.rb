module Users
  class PasswordChangedController < ApplicationController
    # skip_before_action :has_accepted_declaration,
    #                    :has_viewed_introduction,
    #                    :require_secondary_authentication
    skip_before_action :create_or_join_responsible_person

    def show; end
  end
end
