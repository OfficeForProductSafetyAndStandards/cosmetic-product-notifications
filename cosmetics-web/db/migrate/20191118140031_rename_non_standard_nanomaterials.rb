class RenameNonStandardNanomaterials < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :non_standard_nanomaterials, :nanomaterial_notifications
      # rubocop:disable Rails/NotNullColumn
      # (allowed because this table is empty)
      add_column :nanomaterial_notifications, :user_id, :text, null: false
      # rubocop:enable Rails/NotNullColumn
      add_column :nanomaterial_notifications, :eu_notified, :boolean
      add_column :nanomaterial_notifications, :notified_to_eu_on, :date
      add_column :nanomaterial_notifications, :submitted_at, :datetime
    end
  end
end
