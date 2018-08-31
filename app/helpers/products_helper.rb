module ProductsHelper
  include SearchHelper

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(
      :gtin, :name, :description, :model, :batch_number, :brand, :product_type,
      :country_of_origin, :date_placed_on_market
    )
  end

  # If the user supplies a barcode and it matches, then just return that.
  # Otherwise use the general query param

  # TODO: When doing the advanced products search, we should re-evaluate how we do the
  # search on the product creation pages too
  def advanced_product_search(page_size)
    gtin_search_results = search_for_gtin(page_size) if params[:gtin].present?
    # if there was no GTIN param or there were no results for the GTIN search
    full_search_results = search_for_products(page_size) if gtin_search_results.blank? && params[:q].present?
    full_search_results || gtin_search_results || []
  end

  def search_for_products(page_size)
    if search_params_present?
      Product.fuzzy_search(search_params)
             .paginate(page: params[:page], per_page: page_size)
             .records
    else
      Product.paginate(page: params[:page], per_page: page_size)
    end
  end

  def search_for_gtin(page_size)
    Product.search(query: { match: { gtin: params[:gtin] } })
           .paginate(page: params[:page], per_page: page_size)
           .records
  end

  def sort_column
    Product.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
