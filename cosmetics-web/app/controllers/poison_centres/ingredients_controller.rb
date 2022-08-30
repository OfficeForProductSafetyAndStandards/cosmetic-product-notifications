class PoisonCentres::IngredientsController < SearchApplicationController
  PER_PAGE = 200

  def index
    ingredient_list = case params[:sort_by]
                      when "date"
                        Ingredient.unique_names_by_created_last
                      when "name_desc"
                        Ingredient.unique_names.by_name_desc
                      else
                        Ingredient.unique_names.by_name_asc
                      end
    @ingredients = ingredient_list.page(params[:page]).per(PER_PAGE)
  end
end
