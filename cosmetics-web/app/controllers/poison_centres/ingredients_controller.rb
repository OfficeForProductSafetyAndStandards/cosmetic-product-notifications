class PoisonCentres::IngredientsController < SearchApplicationController
  PER_PAGE = 20

  def index
    @ingredients = Ingredient.for_list(order: params[:sort_by]).page(params[:page]).per(PER_PAGE)
  end
end
