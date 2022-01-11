class FrameFormulationsController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def index; end

  def show
    @formulation = FrameFormulations::ALL.find { |formulation| formulation["number"] == params[:id].to_i }
    return redirect_to "/404" if @formulation.blank?

    @subformulation = @formulation["data"].find { |formulation| formulation["childNumber"] == params[:sub_id].to_i }
    return redirect_to "/404" if @subformulation.blank?
  end
end
