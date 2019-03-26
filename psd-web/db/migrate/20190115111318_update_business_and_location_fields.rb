class UpdateBusinessAndLocationFields < ActiveRecord::Migration[5.2]
  class Location < ApplicationRecord; end

  def change
    safety_assured do # rubocop:disable Metrics/BlockLength
      reversible do |dir| # rubocop:disable Metrics/BlockLength
        dir.up do
          create_table :contacts do |t|
            t.string :name
            t.string :email
            t.string :phone_number
            t.string :job_title
            t.integer :business_id
            t.index %w[business_id], name: "index_contacts_on_business_id"
            t.timestamps
          end

          change_table :businesses, bulk: true do |t|
            t.rename :company_name, :trading_name
            t.string :legal_name
            t.remove :nature_of_business_id
            t.remove :additional_information
            t.remove :company_status_code
            t.remove :company_type_code
          end

          change_table :locations, bulk: true do |t|
            t.rename :address, :address_line_1
            t.string :address_line_2
            t.string :city
            t.rename :locality, :county
          end
        end

        dir.down do
          change_table :businesses, bulk: true do |t|
            t.rename :trading_name, :company_name
            t.remove :legal_name
            t.string :nature_of_business_id
            t.text :additional_information
            t.string :company_status_code
            t.string :company_type_code
          end

          change_table :locations, bulk: true do |t|
            Location.all.each do |loc|
              loc.update! address: loc.address_line_1 + ', ' + loc.address_line_2
            end
            t.rename :address_line_1, :address
            t.remove :address_line_2
            t.remove :city
            t.rename :county, :locality
          end

          drop_table :contacts
        end
      end
    end
  end
end
