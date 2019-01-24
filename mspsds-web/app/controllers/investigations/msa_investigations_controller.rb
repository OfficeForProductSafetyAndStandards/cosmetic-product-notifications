class Investigations::MsaInvestigationsController < ApplicationController
  # include FileConcern
  include Wicked::Wizard
  include CountriesHelper

  steps :product, :why_reporting, :which_businesses, :has_corrective_action, :other_information, :reference_number
  before_action :set_product, except: :new
  before_action :set_countries

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

  def set_countries
    @countries = all_countries
  end
end
