class AddDetailsToComponents < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :components, bulk: true do |t|
        t.string :physical_form
        t.string :special_applicator
        t.string :acute_poisoning_info
      end
    end
  end
end
