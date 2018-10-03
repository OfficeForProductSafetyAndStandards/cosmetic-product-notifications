module ProductsHelper
  include SearchHelper

  SUGGESTED_PRODUCTS_LIMIT = 4

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(
      :gtin, :name, :description, :model, :batch_number, :brand, :product_type,
      :country_of_origin, :date_placed_on_market
    )
  end

  def search_for_products(page_size)
    Product.full_search(search_query)
      .paginate(page: params[:page], per_page: page_size)
      .records
  end

  def sort_column
    Product.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # If the user supplies a barcode then just return that.
  # Otherwise use the general query param

  # TODO: When doing the advanced products search, we should re-evaluate how we do the
  # search on the product creation pages too
  def advanced_product_search(product, excluded_ids = [])
    if product.gtin.present?
      search_for_gtin(product.gtin, excluded_ids)
    else
      fuzzy_fields = {
        "name": product.name,
        "brand": product.brand,
        "product_type": product.product_type
      }.reject { |_, value| value.blank? }.
        map do |field, value|
        {
          fuzzy: { "#{field}": value }
        }
      end
      Product.search(query: {
        bool: {
          should: fuzzy_fields,
          must_not: have_excluded_id(excluded_ids)
        }
      })
        .paginate(per_page: SUGGESTED_PRODUCTS_LIMIT)
        .records
    end
  end

  def search_for_gtin(gtin, excluded_ids)
    match_gtin = { match: { gtin: gtin } }
    Product.search(query: {
      bool: {
        must: match_gtin,
        must_not: have_excluded_id(excluded_ids),
      }
    })
      .paginate(per_page: SUGGESTED_PRODUCTS_LIMIT)
      .records
  end

  def create_product
    if params[:product].present?
      @product = Product.new(product_params)
      @product.source = UserSource.new(user: current_user)
    else
      @product = Product.new
    end
  end

  def set_countries
    @countries = all_countries
  end

  def set_product
    @product = Product.find(params[:id])
  end

private

  def have_excluded_id(excluded_ids)
    {
      ids: {
        values: excluded_ids.map(&:to_s)
      }
    }
  end
end
