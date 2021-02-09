
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
  select_radio(answer)
  click_button "Continue"
end

def select_manual_notification(answer)
	expected_h1('EU notification ZIP files')
	select_radio(answer)
	click_button "Continue"
end

def select_manual_notification_prebexit_or_post_brexit(answer)
	expected_h1('Was this product notified in the EU before 1 January 2021?')
	select_radio(answer)
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
	select_radio('No')
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('Is the product intended to be used on children under 3 years old?')
	select_radio('Yes')
	click_button "Continue"
end
	expected_h1('Multi-item kits')
	select_radio('No, this is a single product')
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('Upload an image of the product label')
	page.attach_file('spec/cucumber/face_covering.JPG.jpg')
	click_button "Continue"
	end
	expected_h1('Is the the product available in different shades?')
	select_radio('No')
	click_button "Continue"
	#choose physical form
	expected_h1('What is the physical form of the the product?')
	select_radio('Solid or pressed powder')
	click_button "Continue"
	if(notification =='post brexit')
	expected_h1('What is the the product contained in?')
	choose('A typical non-pressurised bottle, jar, sachet or other package',visible: false)
	click_button "Continue"
	#choose cmrs 
	expected_h1('Carcinogenic, mutagenic or reprotoxic substances')
	select_radio('Yes')
	click_button "Continue"
	expected_h1('List category 1A or 1B CMRs')
	click_on('Back')
	select_radio('No')
	click_button "Continue"
end
	expected_h1('Nanomaterials')
	select_radio('No')
	click_button "Continue"
	expected_h1('What category of cosmetic product is it?')
	select_radio('Skin products')
	click_button "Continue"
	expected_h1('What category of skin products is the product?')
	select_radio('Skin care products')
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

def validate_check_your_answer_page(product_name,product_category,product_formulation)
	expect(page).to have_summary_item(key: "Name", value: product_name)
	expect(page).to have_summary_item(key: "Name", value: product_cateogry)
	expect(page).to have_summary_item(key: "Name", value: product_formulation)
	end
	

def select_radio(option)
	choose(option,visible: false)
end


def expected_h1(h1)
	expect(page).to have_selector("h1",text: h1)
end

def have_summary_item(key:, value:)
    HaveSummaryItem.new(key: key, value: value)
  end