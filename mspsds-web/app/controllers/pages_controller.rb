class PagesController < ApplicationController
  def terms_and_conditions
    @referred = params[:referred]
  end

  def about
    @referred = params[:referred]
  end
end
