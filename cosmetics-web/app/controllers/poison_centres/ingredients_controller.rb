class PoisonCentres::IngredientsController < SearchApplicationController
  PER_PAGE = 20

  def index
    @ingredients = ExactFormula.select("distinct(inci_name)").order("inci_name").page(params[:page]).per(PER_PAGE)
  end
end
