class HomepageController < ApplicationController
  def show
    if current_user.is_opss?
      redirect_to investigations_path
    elsif !current_user.is_opss?
      render "non_opss"
    end
  end
end
