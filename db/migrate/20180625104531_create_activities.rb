class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.references :investigation, type: :uuid, foreign_key: true
      t.references :activity_type, type: :uuid, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
