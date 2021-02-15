class FrameFormulationsController < ApplicationController
  def index
  end

  def show
    @formulation = FrameFormulations::ALL[params[:id].to_i]
    @subformulation = @formulation["data"][params[:sub_id].to_i]
  end
end
