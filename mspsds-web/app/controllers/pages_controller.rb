class PagesController < ApplicationController
  before_action :set_referred

  def terms_and_conditions; end

  def privacy_policy; end

  def about; end

private

  def set_referred
    @referred = params[:referred]
  end
end
