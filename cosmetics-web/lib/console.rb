prompt = "Cosmetics#\e[#{IRB::Color::RED}m#{Rails.env}\e[0m"

# defining custom prompt
IRB.conf[:PROMPT][:RAILS] = {
  PROMPT_I: "#{prompt} > ",
  PROMPT_N: "#{prompt}> ",
  PROMPT_S: "#{prompt}* ",
  PROMPT_C: "#{prompt}? ",
  RETURN: " => %s\n",
}

# Setting our custom prompt as prompt mode
IRB.conf[:PROMPT_MODE] = :RAILS
