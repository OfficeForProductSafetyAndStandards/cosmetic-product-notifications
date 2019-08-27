class AddMoreEnquiryDetailsToInvestigations < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :investigations, bulk: true do |t|
        t.date :date_received
        t.string :received_type
      end
    end
  end
end
