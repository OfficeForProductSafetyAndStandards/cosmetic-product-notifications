class PoisonCentres::IngredientsController < SearchApplicationController
  include ResponsiblePersonQueryConcern

  def index
    return redirect_to root_path unless helpers.can_view_ingredients_list?

    ingredient_list = case params[:sort_by]
                      when "date"
                        Ingredient.unique_names_by_created_last
                      when "name_desc"
                        Ingredient.unique_names.by_name_desc
                      else
                        Ingredient.unique_names.by_name_asc
                      end
    @ingredients = ingredient_list.page(params[:page]).per(200)
  end

  def responsible_persons
    return redirect_to root_path unless helpers.can_view_ingredients_list?
    return redirect_to poison_centre_ingredients_path if params[:ingredient_inci_name].blank?

    sort_by = case params[:sort_by]
              when "most_notifications"
                "total_notifications desc"
              when "name_desc"
                "responsible_persons.name desc"
              else
                "responsible_persons.name asc"
              end

    @responsible_persons = responsible_persons_by_notified_ingredient(params[:ingredient_inci_name], sort_by:, page: params[:page], per_page: 100)
  end

  def responsible_person_notifications
    return redirect_to root_path unless helpers.can_view_ingredients_list?
    return redirect_to poison_centre_ingredients_path if params[:ingredient_inci_name].blank?

    sort_by = case params[:sort_by]
              when "date"
                "notifications.created_at desc"
              when "name_desc"
                "notifications.product_name desc"
              else
                "notifications.product_name asc"
              end

    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    @notifications = notifications_by_notified_ingredient(params[:ingredient_inci_name], responsible_person: @responsible_person, sort_by:, page: params[:page], per_page: 20)
  end
end
