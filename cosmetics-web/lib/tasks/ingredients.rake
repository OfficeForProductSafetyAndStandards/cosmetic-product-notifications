namespace :ingredients do
  desc "Migrate ingredients data from ExactFormula and RangeFormula to Ingredient"

  task migrate_data: :environment do
    ActiveRecord::Base.transaction do
      puts "Migrating data from ExactFormula to Ingredient..."
      ExactFormula.find_each do |exact_formula|
        next if exact_formula.component.nil? ||
          exact_formula.inci_name.blank? ||
          exact_formula.quantity.blank? ||
          exact_formula.quantity.zero?

        Ingredient.create!(
          component: exact_formula.component,
          inci_name: exact_formula.inci_name,
          exact_concentration: exact_formula.quantity,
          range_concentration: nil,
          created_at: exact_formula.created_at,
          updated_at: exact_formula.updated_at,
        )
      end
      puts "Migrating data from RangeFormula to Ingredient..."
      RangeFormula.find_each do |range_formula|
        next if range_formula.component.nil? || range_formula.inci_name.blank? || range_formula.range.blank?

        Ingredient.create!(
          component: range_formula.component,
          inci_name: range_formula.inci_name,
          range_concentration: range_formula.range,
          exact_concentration: nil,
          created_at: range_formula.created_at,
          updated_at: range_formula.updated_at,
        )
      end
      puts "All data from Exact and Range Formulas has been migrated to Ingredient."
    end
  end
end
