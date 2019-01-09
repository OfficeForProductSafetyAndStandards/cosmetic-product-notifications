class HomepageController < ApplicationController
  def show
    if current_user.is_office?
      return redirect_to investigations_path
    elsif !current_user.is_office?
      return render "non_office"
    end
  end
end
