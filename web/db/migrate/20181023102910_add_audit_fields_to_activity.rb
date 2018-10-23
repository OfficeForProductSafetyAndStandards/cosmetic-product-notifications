class AddAuditFieldsToActivity < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :activities, :title, :string
    add_column :activities, :subtitle_slug, :string
    add_reference :activities, :business, foreign_key: true, index: false
    add_index :activities, :business_id, algorithm: :concurrently
  end
end
