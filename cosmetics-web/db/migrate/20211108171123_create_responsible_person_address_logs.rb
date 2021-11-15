class CreateResponsiblePersonAddressLogs < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      create_table :responsible_person_address_logs do |t|
        t.string :line_1, null: false
        t.string :line_2
        t.string :city, null: false
        t.string :county
        t.string :postal_code, null: false
        t.datetime :start_date, null: false
        t.datetime :end_date, null: false

        t.timestamps
      end

      # rubocop:disable Rails/NotNullColumn
      add_reference :responsible_person_address_logs,
                    :responsible_person,
                    null: false,
                    foreign_key: true,
                    index: false
      # rubocop:enable Rails/NotNullColumn
      add_index :responsible_person_address_logs,
                :responsible_person_id,
                algorithm: :concurrently,
                name: :index_responsible_person_address_logs_on_rp_id
    end
  end
end
