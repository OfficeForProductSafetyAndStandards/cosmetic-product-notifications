class IntroductionsController < ApplicationController
  include Wicked::Wizard

  steps :overview, :report_products, :track_investigations, :share_data

  before_action :set_has_viewed_introduction

  def new
    redirect_to wizard_path(steps.first)
  end

  def show
    render_wizard
  end

  def set_has_viewed_introduction
    User.current.update has_viewed_introduction: true
  end
end
