class CreateSources < ActiveRecord::Migration[5.2]
  def change
    create_table :sources, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :type
      t.string :name
      t.references :user, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
