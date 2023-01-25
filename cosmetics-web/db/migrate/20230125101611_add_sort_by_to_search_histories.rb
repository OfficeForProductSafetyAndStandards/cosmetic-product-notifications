class AddSortByToSearchHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :search_histories, :sort_by, :string
  end
end
