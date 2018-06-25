class CreateActivityTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_types, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name

      t.timestamps
    end
  end
end
