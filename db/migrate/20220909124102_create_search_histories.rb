class CreateSearchHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :search_histories do |t|
      t.string :query
      t.integer :results

      t.timestamps
    end
  end
end
