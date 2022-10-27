class IngredientNameFormatValidator < NameFormatValidator
  BANNED_REGEXP = /<\/|www|http/
end
