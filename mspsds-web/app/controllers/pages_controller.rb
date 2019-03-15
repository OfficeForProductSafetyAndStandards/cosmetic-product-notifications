class PagesController < ApplicationController
  def show

  end

  def terms_and_conditions
    @referred = params[:referred]
  end
end
