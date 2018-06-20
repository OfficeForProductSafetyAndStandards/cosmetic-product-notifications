class CreateJoinTableProductsInvestigations < ActiveRecord::Migration[5.2]
  def change
    create_join_table :products, :investigations do |t|
      t.uuid :product_id
      t.uuid :investigation_id
    end
  end
end
