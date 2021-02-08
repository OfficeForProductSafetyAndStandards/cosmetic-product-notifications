
def sign_in_as_business
   visit(ENV["ENV_URL"])
   click_on('sign in')
   fill_in "submit_user[email]", with: ENV["smoke_user"]
   fill_in "submit_user[password]", with: ENV["smoke_user_pwd"]
   click_button "Continue"
   fill_in "secondary_authentication_form[otp_code]", with: "11222"
   click_button "Continue"
   sleep 5
end

def answer_was_eu_notified_with(answer)
  choose(answer,visible: false)
  click_button "Continue"
end

def select_manual_notification(answer)
	expected_h1('EU notification ZIP files')
	choose(answer,visible: false)
	click_button "Continue"
end

def select_manual_notification_prebexit_or_post_brexit(answer)
	expected_h1('Was this product notified in the EU before 1 January 2021?')
	choose(answer,visible: false)
	click_button "Continue"
end

def enter_product_name(product_name)
	expected_h1('What’s the product called?')
	fill_in "notification_product_name", with: product_name
	click_button "Continue"
	sleep 5
end

def notify_product(notification)
	expected_h1('Internal reference')
	choose('No',visible: false)
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('Is the product intended to be used on children under 3 years old?')
	choose('Yes',visible: false)
	click_button "Continue"
end
	expected_h1('Multi-item kits')
	choose('No, this is a single product',visible: false)
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('Upload an image of the product label')
	page.attach_file('spec/cucumber/face_covering.JPG.jpg')
	click_button "Continue"
	end
	expected_h1('Is the the product available in different shades?')
	choose('No',visible: false)
	click_button "Continue"
	#choose physical form
	expected_h1('What is the physical form of the the product?')
	choose('Solid or pressed powder',visible: false)
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('What is the the product contained in?')
	choose('A typical non-pressurised bottle, jar, sachet or other package',visible: false)
	click_button "Continue"
	#choose cmrs 
	expected_h1('Carcinogenic, mutagenic or reprotoxic substances')
	choose('Yes',visible: false)
	click_button "Continue"
	expected_h1('List category 1A or 1B CMRs')
	click_on('Back')
	choose('No',visible: false)
	click_button "Continue"
end
	expected_h1('Nanomaterials')
	choose('No',visible: false)
	click_button "Continue"
	expected_h1('What category of cosmetic product is it?')
	choose('Skin products',visible: false)
	click_button "Continue"
	expected_h1('What category of skin products is the product?')
	choose('Skin care products',visible: false)
	click_button "Continue"
	expected_h1('What category of skin care products is the product?')
	choose('Face care products other than face mask',visible: false)
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('How do you want to give the formulation of the product?')
	choose('List ingredients and their exact concentration',visible: false)
	click_button "Continue"
	expected_h1('Exact concentrations of the ingredients')
	page.attach_file('spec/cucumber/Ingredients_test.pdf')
	click_button "Continue"
	else 
	fill_in("component_frame_formulation",with: "Skin\n")
    click_button "Continue"
    expected_h1('Ingredients the National Poison Information Service needs to know about')
    choose('No',visible: false)
    click_button "Continue"
	end

	expected_h1('What is the pH range of the product?')
	choose('It does not have a pH',visible: false)
	click_button "Continue"
   #Test summary page
  if(notification =='post brexit')
   expected_h1('smoke test post-brexit manual notification')
else 
	expected_h1('smoke test pre-brexit manual notification')
end

end






def expected_h1(h1)
	expect(page).to have_selector("h1",text: h1)
end
