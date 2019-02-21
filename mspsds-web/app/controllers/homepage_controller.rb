class HomepageController < ApplicationController
  def show
    if User.current.is_opss?
      redirect_to investigations_path
    else
      render "non_opss"
    end
  end
end
