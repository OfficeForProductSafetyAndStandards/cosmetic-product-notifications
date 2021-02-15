class FrameFormulationsController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def index
  end

  def show
    @formulation = FrameFormulations::ALL[params[:id].to_i]
    @subformulation = @formulation["data"][params[:sub_id].to_i]
  end
end
