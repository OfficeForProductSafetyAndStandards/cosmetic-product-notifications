class DropRapexImages < ActiveRecord::Migration[5.2]
  def up
    drop_table :rapex_images
  end

  def down
    create_table "rapex_images", id: :serial, force: :cascade do |t|
      t.datetime "created_at", null: false
      t.integer "product_id"
      t.string "title"
      t.datetime "updated_at", null: false
      t.string "url"
      t.index %w[product_id], name: "index_rapex_images_on_product_id"
    end

    add_foreign_key "rapex_images", "products"
  end
end
