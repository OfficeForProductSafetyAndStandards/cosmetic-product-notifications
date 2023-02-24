class PubliclyAccessibleController < ApplicationController
  skip_before_action :authenticate_user!

  def root
    UnusedCodeAlerting.alert
    redirect_to "/"
  end
end
