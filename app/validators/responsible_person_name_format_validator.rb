class ResponsiblePersonNameFormatValidator < NameFormatValidator
  BANNED_REGEXP = /<|>|\n|http/
end
