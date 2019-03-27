class RefactorAddressesIntoLocations < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        rename_table :addresses, :locations
        change_table :locations do |t|
          t.rename :address_type, :name
          t.string :phone_number

          dir.up do
            Location.all.each do |address|
              address.update! line_1: "#{address.line_1}, #{address.line_2}"
            end
            t.rename :line_1, :address
            t.remove :line_2
          end

          dir.down do
            t.rename :address, :line_1
            t.string :line_2
            Location.all.each do |address|
              lines = address.line_1.split(/\s*,\s*/)
              address.update! line_1: lines[0], line_2: lines[1..-1].join(", ")
            end
          end
        end
      end
    end
  end
end
