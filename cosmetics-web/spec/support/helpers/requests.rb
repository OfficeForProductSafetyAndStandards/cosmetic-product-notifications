def optional_spaces(text)
  /\s*#{text.gsub(" ", '\s*')}\s*/
end
