class PubliclyAccessibleController < ApplicationController
  skip_before_action :authenticate_user!

  def root
    if submit_domain?
      redirect_to "/"
    else
      redirect_to "/"
    end
  end
end
