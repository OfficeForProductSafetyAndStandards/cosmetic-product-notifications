class IntroductionController < ApplicationController
  def overview; end

  def report_products; end

  def track_investigations; end

  def share_data
    User.current.has_viewed_introduction!
  end

  def skip
    User.current.has_viewed_introduction!
    redirect_to root_path
  end
end
