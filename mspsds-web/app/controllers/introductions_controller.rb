class IntroductionsController < ApplicationController
  include Wicked::Wizard

  steps :overview, :report_products, :track_investigations, :share_data

  def new
    redirect_to wizard_path(steps.first)
  end

  def show
    render_wizard
  end
end
