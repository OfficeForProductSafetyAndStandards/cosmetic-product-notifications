class RemoveDatePlacedOnMarketFromProduct < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :products do |t|
          dir.up do
            t.remove :date_placed_on_market
          end

          dir.down do
            t.date :date_placed_on_market
          end
        end
      end
    end
  end
end
