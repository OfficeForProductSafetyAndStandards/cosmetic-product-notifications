class HomepageController < ApplicationController
  def show
    if current_user.is_opss?
      redirect_to investigations_path
    else
      render "non_opss"
    end
  end
end
