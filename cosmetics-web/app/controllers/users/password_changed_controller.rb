module Users
  class PasswordChangedController < ApplicationController
    skip_before_action :create_or_join_responsible_person

    def show; end
  end
end
