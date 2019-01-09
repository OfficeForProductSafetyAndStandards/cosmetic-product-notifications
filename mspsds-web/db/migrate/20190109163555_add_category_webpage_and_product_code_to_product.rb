class AddCategoryWebpageAndProductCodeToProduct < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :products do |t|
        reversible do |dir|
          dir.up do
            t.string :product_code
            t.string :category
            t.string :webpage
          end

          dir.down do
            t.remove :product_code
            t.remove :category
            t.remove :webpage
          end
        end
      end
    end
  end
end
