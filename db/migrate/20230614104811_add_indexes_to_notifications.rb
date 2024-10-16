class AddIndexesToNotifications < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # `product_name` needs to use a GIN index rather than BTREE since it can
    # contain strings that exceed the index size limit.
    enable_extension "pg_trgm"
    add_index :notifications, :product_name, algorithm: :concurrently, using: :gin, opclass: :gin_trgm_ops, if_not_exists: true
    add_index :notifications, :state, algorithm: :concurrently, if_not_exists: true
    add_index :notifications, :notification_complete_at, algorithm: :concurrently, if_not_exists: true
    add_index :deleted_notifications, :product_name, algorithm: :concurrently, using: :gin, opclass: :gin_trgm_ops, if_not_exists: true
    add_index :deleted_notifications, :state, algorithm: :concurrently, if_not_exists: true
    add_index :deleted_notifications, :notification_complete_at, algorithm: :concurrently, if_not_exists: true
  end
end
