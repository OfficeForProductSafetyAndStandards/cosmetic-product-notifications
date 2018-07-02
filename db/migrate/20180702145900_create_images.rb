class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :title
      t.string :url
      t.belongs_to :product, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
