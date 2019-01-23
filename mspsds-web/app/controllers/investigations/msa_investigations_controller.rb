class Investigations::MsaInvestigationsController < ApplicationController
  # include FileConcern
  include Wicked::Wizard

  steps :product, :why_reporting
  before_action :set_product, except: :new

  #GET /xxx/step
  def show
    render_wizard
  end

  # GET /xxx/new
  def new
    clear_session # functionality not implemented
    redirect_to wizard_path(steps.first)
  end

  # PATCH/PUT /xxx
  def update
    redirect_to next_wizard_path
  end

private

  def set_product
    @product = Product.new
  end

  def clear_session
  end
end
