class RefactorAddressesIntoLocations < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :locations do |t|
          dir.up do
            Location.all.each do |address|
              address.update! line_1: "#{address.line_1}, #{address.line_2}"
            end
            t.rename :address_type, :name
            t.rename :line_1, :address
            t.remove :line_2
            t.string :phone_number
            rename_table :locations, :locations
          end

          dir.down do
            rename_table :locations, :locations
            t.rename :name, :address_type
            t.rename :line_1, :address
            t.string :line_2
            t.remove :phone_number
            Location.all.each do |address|
              lines = address.address.split(/\s*,\s*/)
              address.update! line_1: lines[0], line_2: lines[1]
            end
          end
        end
      end
    end
  end
end
