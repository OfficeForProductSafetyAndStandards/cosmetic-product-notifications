# frozen_string_literal: true

class ChangeFlipperGatesValueToText < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    return unless connection.column_exists? :flipper_gates, :value, :string

    if index_exists? :flipper_gates, %i[feature_key key value]
      remove_index :flipper_gates, %i[feature_key key value]
    end

    change_column :flipper_gates, :value, :text
    add_index :flipper_gates, %i[feature_key key value], unique: true, length: { value: 255 }, algorithm: :concurrently
  end

  def down
    if index_exists? :flipper_gates, %i[feature_key key value]
      remove_index :flipper_gates, %i[feature_key key value], algorithm: :concurrently
    end

    change_column :flipper_gates, :value, :string
  end
end
