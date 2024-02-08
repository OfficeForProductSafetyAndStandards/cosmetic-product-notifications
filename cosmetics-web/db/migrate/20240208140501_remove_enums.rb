class RemoveEnums < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      change_column :ingredients, :range_concentration, :string
      change_column :users, :role, :string

      drop_enum :ingredient_range_concentration
      drop_enum :user_roles
    end
  end

  def down
    safety_assured do
      create_enum :ingredient_range_concentration, %w[less_than_01_percent greater_than_01_less_than_1_percent greater_than_1_less_than_5_percent greater_than_5_less_than_10_percent greater_than_10_less_than_25_percent greater_than_25_less_than_50_percent greater_than_50_less_than_75_percent greater_than_75_less_than_100_percent]
      create_enum :user_roles, %w[poison_centre opss_science opss_general opss_enforcement trading_standards opss_imt]

      change_column :ingredients, :range_concentration, :enum, enum_type: "ingredient_range_concentration"
      change_column :users, :role, :enum, enum_type: "user_roles"
    end
  end
end
