class RefactorActivities < ActiveRecord::Migration[5.2]
  def change
    drop_table :activities # rubocop:disable Rails/ReversibleMigration

    create_table :activities do |t|
      t.actable
      t.integer "investigation_id"
      t.text :description
      t.timestamps
      t.index %w[investigation_id], name: "index_activities_on_investigation_id"
    end
    add_foreign_key "activities", "investigations"

    create_table :comment_activities # rubocop:disable Rails/CreateTableWithTimestamps
  end
end
