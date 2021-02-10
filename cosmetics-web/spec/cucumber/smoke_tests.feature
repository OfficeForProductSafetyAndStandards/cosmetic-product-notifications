Feature: Smoke test

@smoke
Scenario: Login as business user
Given I login as business user 
Then I should be redirected to dashboard page

@smoke
Scenario: notify pre-brexit product manually
Given I login as business user
When I click add cosmetics product
And I select "Yes" notified in EU
And I select "No, I’ll enter information manually"
Then I should be able to notify "pre-brexit" product "smoke test pre-brexit manual notification" in category "Skin products" and given formulation as "Frame formulation"
And I should be able to submit product successfully

@smoke
Scenario: Notify post jan 2021 product manually
Given I login as business user
When I click add cosmetics product
And I select notified in EU "No"
And I select are you likely to notify in EU "No"
Then I should be able to notify "post brexit" product "smoke test post-brexit manual notification" in category "Skin products" and formulation given as "List ingredients and their exact concentration"
And I should be able to see the entered details product name "smoke test post-brexit manual notification" and category "Skin products" and given formulation as "Exact concentration"
And I should be able to submit product successfully

@smoke
Scenario: Notify product using zip file
Given I login as business user
When I click add cosmetics product
And I select notified in EU "Yes"
And I select I have zip file "Yes"
Then I should be redirected to zip file upload page
And I should be able to upload valid zip file successfully
