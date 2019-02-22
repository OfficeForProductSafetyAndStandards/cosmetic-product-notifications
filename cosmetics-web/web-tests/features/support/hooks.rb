require 'net/http'

Before do
  #Capybara.page.current_window.manage.window.maximize
end


After do |scenario|
if scenario.failed?
url = URI.parse(current_url)
res = Net::HTTP.get_response(URI(current_url))
puts "reponse code =>" + res.code
puts "response message =>" + res.message
puts url
puts "Timestamp at which test failed :" + (Time.now).inspect
end
end


def add_browser_logs
 time_now = Time.now
 # Getting current URL
 current_url = Capybara.current_url.to_s
 # Gather browser logs
 logs = page.driver.browser.manage.logs.get(:browser).map {|line| [line.level, line.message]}
# Remove warnings and info messages
 logs.reject! { |line| ['WARNING', 'INFO'].include?(line.first) }
 logs.any? == true

 embed(time_now.strftime('%Y-%m-%d-%H-%M-%S' + "\n") + ( "Current URL: " + current_url + "\n") + logs.join("\n"), 'text/plain', 'BROWSER ERROR')
end