class RefactorAddressesIntoLocations < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :locations do |t|
          dir.up do
            Address.all.each do |address|
              address.update! line_1: "#{address.line_1}, #{address.line_2}"
            end
            t.rename :address_type, :name
            t.rename :line_1, :address
            t.remove :line_2
            t.string :phone_number
            rename_table :addresses, :locations
          end

          dir.down do
            rename_table :locations, :addresses
            t.rename :name, :address_type
            t.rename :address, :line_1
            t.string :line_2
            t.remove :phone_number
            Address.all.each do |address|
              lines = address.line_1.split(/\s*,\s*/)
              address.update! line_1: lines[0], line_2: lines[1]
            end
          end
        end
      end
    end
  end
end
