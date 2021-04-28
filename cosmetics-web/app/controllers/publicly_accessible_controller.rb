class PubliclyAccessibleController < ApplicationController
  skip_before_action :authenticate_user!

  def root
    redirect_to "/"
  end
end
