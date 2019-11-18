class RenameNonStandardNanomaterials < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :non_standard_nanomaterials, :nanomaterial_notifications
      add_column :nanomaterial_notifications, :user_id, :text, null: false
      add_column :nanomaterial_notifications, :notified_to_eu_on, :date
      add_column :nanomaterial_notifications, :submitted_at, :datetime
    end
  end
end
