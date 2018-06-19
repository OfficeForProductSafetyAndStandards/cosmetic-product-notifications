class CreateInvestigations < ActiveRecord::Migration[5.2]
  def change
    create_table :investigations, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.text :description
      t.boolean :is_closed
      t.string :source
      t.integer :severity
      t.references :product, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
