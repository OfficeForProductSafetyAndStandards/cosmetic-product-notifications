class UserNameFormatValidator < NameFormatValidator
  BANNED_REGEXP = /:|\/|@|<|>|,|\.|\n|www|http|!|“|"|£|\$|%|\^|&|\*|\(|\)|_|\+|¬/
end
