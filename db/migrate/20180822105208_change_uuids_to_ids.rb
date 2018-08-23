class ChangeUuidsToIds < ActiveRecord::Migration[5.2]

  def up
    tables = [
        "sources",
        "products",
        "businesses",
        "investigations",
        "rapex_images",
        "addresses",
        "activities"
    ]

    tables.each do |table|
      add_column table, :new_id, :serial
    end

    uuid_to_id("activities", "investigation", "investigation")
    uuid_to_id("addresses", "business", "business")
    uuid_to_id("rapex_images", "product", "product")
    uuid_to_id("investigation_businesses", "business", "business")
    uuid_to_id("investigation_businesses", "investigation", "investigation")
    uuid_to_id("investigation_products", "investigation", "investigation")
    uuid_to_id("investigation_products", "product", "product")
    uuid_to_id_for_sourceable("sources", "sourceable")
    uuid_to_id_for_versions("versions", "item")

    tables.each do |table|
      remove_column table, :id
      rename_column table, :new_id, :id
      execute "ALTER TABLE #{table} ADD PRIMARY KEY (id);"
      execute "ALTER SEQUENCE #{table}_new_id_seq RENAME TO #{table}_id_seq;"
    end

    add_index :investigation_businesses, [ :investigation_id, :business_id ], unique: true,
              name: "index_on_investigation_id_and_business_id"
    add_index :investigation_products, [ :investigation_id, :product_id ], unique: true
    add_foreign_key "activities", "investigations"
    add_foreign_key "addresses", "businesses"
    add_foreign_key "rapex_images", "products"
  end

  def uuid_to_id(table_name, relation_name, relation_class)
    table_name = table_name.to_sym
    klass = table_name.to_s.classify.constantize
    relation_klass = relation_class.to_s.classify.constantize
    foreign_key = "#{relation_name}_id".to_sym
    new_foreign_key = "#{relation_name}_new_id".to_sym

    add_column table_name, new_foreign_key, :integer

    klass.where.not(foreign_key => nil).each do |record|
      if associated_record = relation_klass.find_by(id: record.send(foreign_key))
        record.update_column(new_foreign_key, associated_record.new_id)
      end
    end

    remove_column table_name, foreign_key
    rename_column table_name, new_foreign_key, foreign_key
    add_index table_name, foreign_key
  end

  def uuid_to_id_for_sourceable(table_name, relation_name)
    sourceable_tables = [
        "products",
        "businesses",
        "investigations",
        "addresses",
        "activities"
    ]

    table_name = table_name.to_sym
    klass = table_name.to_s.classify.constantize
    foreign_key = "#{relation_name}_id".to_sym
    new_foreign_key = "#{relation_name}_new_id".to_sym

    add_column table_name, new_foreign_key, :integer

    sourceable_tables.each do |relation_class|
      relation_klass = relation_class.to_s.classify.constantize
      relation_klass.all.each do |associated_record|
        associated_record.source.update_column(new_foreign_key, associated_record.new_id)
      end
    end

    remove_column table_name, foreign_key
    rename_column table_name, new_foreign_key, foreign_key
  end

  def uuid_to_id_for_versions(table_name="versions", relation_name="item")
    versioned_tables = [
        "products",
        "businesses",
        "investigations",
        "addresses",
        "activities"
    ]

    table_name = table_name.to_sym
    foreign_key = "#{relation_name}_id".to_sym
    new_foreign_key = "#{relation_name}_new_id".to_sym

    add_column table_name, new_foreign_key, :integer

    versioned_tables.each do |relation_class|
      relation_klass = relation_class.to_s.classify.constantize
      relation_klass.all.each do |associated_record|
        associated_record.versions.each do | record |
          record.update_column(new_foreign_key, associated_record.new_id)
        end
      end
    end

    remove_column table_name, foreign_key
    rename_column table_name, new_foreign_key, foreign_key

    add_index :versions, ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end
end
