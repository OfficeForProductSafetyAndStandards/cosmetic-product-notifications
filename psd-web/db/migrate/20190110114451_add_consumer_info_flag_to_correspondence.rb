class AddConsumerInfoFlagToCorrespondence < ActiveRecord::Migration[5.2]
  safety_assured do
    change_table :correspondences, bulk: true do |t|
      t.boolean :has_consumer_info, null: false, default: false
    end
  end
end
