module UsersHelper
  include SearchHelper

  def search_for_users(page_size)
    User.prefix_search(search_params, :email)
        .paginate(page: params[:page], per_page: page_size)
        .records
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "email"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
