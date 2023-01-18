Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "gov_uk" => "GovUK",
    "send_submit_sms" => "SendSubmitSMS",
    "send_search_sms" => "SendSearchSMS",
  )
end
