class CreateFooBars < ActiveRecord::Migration[6.1]
  def change
    create_table :foo_bars do |t|
      t.string :foo

      t.timestamps
    end
  end
end
