
Given('I login as business user') do
   visit('https://cosmetics:staging-is-protected-now@staging-submit.cosmetic-product-notifications.service.gov.uk/')
   click_on('sign in')
   fill_in "submit_user[email]", with: "nasirkhan.beis@gmail.com"
   fill_in "submit_user[password]", with: "Nasir@123"
   click_button "Continue"
   fill_in "secondary_authentication_form[otp_code]", with: "11222"
   click_button "Continue"
   expect(page).to have_selector("h1", text: 'Choose Responsible Person')
end

Then('I should be navigated to dashboard page') do
	click_on('Nasir Khan')
   expect(page).to have_selector("h1", text: 'Your cosmetic products')
  end


When('I click add cosmetics product') do
  click_on('Nasir Khan')
  click_on('Add cosmetics products')
end

When('I select Yes notified in EU') do
  expect(page).to have_selector("h1", text:'Has the EU been notified about these products using CPNP?')
  sleep 3
  page.choose("Yes")
  
  click_button "Continue"
  
end

Then('I should be able to notify product manually') do
 
end