module PoisonCentres
  class IngredientNameMatcher
    def self.match(query, notification)
      matched = []

      query_ingredients = query.split(" ")

      ingredient_names = notification.ingredients.map(&:inci_name)
      ingredient_names.each do |notification_ingredient|
        query_ingredients.each do |query_ingredient|
          matched << notification_ingredient if notification_ingredient.downcase.include? query_ingredient.downcase
          matched << notification_ingredient if query_ingredient.downcase.include? notification_ingredient.downcase
        end
      end

      # We know that elastic search matched this search, so we need to log miss so we can improve
      if matched.nil?
        Rails.logger.info("[IngredientSearch] #{query} can not be find in #{notification.id}")
      end

      matched.uniq
    end
  end
end
