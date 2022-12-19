class CreateTestStuffs < ActiveRecord::Migration[6.1]
  def change
    create_table :test_stuffs do |t|
      t.string :foo

      t.timestamps
    end
  end
end
