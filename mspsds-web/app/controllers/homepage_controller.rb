class HomepageController < ApplicationController
  def show
    if User.current.is_opss?
      redirect_to investigations_path
    elsif User.current.has_viewed_introduction
      render "non_opss"
    else
      redirect_to introduction_overview_path
    end
  end
end
