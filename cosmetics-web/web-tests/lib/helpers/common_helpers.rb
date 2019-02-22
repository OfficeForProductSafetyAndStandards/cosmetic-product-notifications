module CommonHelpers

def generate_string(number)
 charset = Array('A'..'Z') + Array('a'..'z')
   Array.new(number) {charset.sample}.join
end

def launch_url(env)
    visit(env)
    expect(page).to have_title "Landing Page - Cosmetics Portal"
    end

def login(username,pwd)
  if(expect(page).to have_content('Sign in'))
  find(:xpath,"//a[contains(.,'Sign in')]").click
  fill_in('username', :with => username  )
  fill_in('password', :with => pwd  )
  find(:xpath,"//input[@type='submit']").click
  sleep 4
  else
  puts 'You are already signed In'
  end
  expect(page).to have_content('Show my cosmetic products');

end

def custom_click(link)
    if(page.has_xpath?("//a[contains(.,'#{link}')]"))
      find(:xpath,"//a[contains(.,'#{link}')]").click
      else
      puts 'Element not found,Please check manually'
      end
     end


def isElementPresent(element)
    if(page.has_xpath?("//a[contains(.,'#{element}')]"))
    else
    puts "expected element not found"
    end
   end

def fill_reg_form
    fill_in('firstName',:with => 'Test')
    fill_in('email',:with => 'Test@example.com')
    fill_in('password',:with => 'Test@123')
    fill_in('password-confirm',:with => 'Test@123')
    end

def logout
    if(expect(page).to have_content('Sign out'))
    find(:xpath,"//a[contains(.,'Sign out')]").click
    sleep 4
    else
    puts "Already Signed Out"
    end
end




end
