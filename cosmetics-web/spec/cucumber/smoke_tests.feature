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
Then I should be able to notify "pre-brexit" product "smoke test pre-brexit manual notification"

@smoke
Scenario: notify post jan 2021 product manually
Given I login as business user
When I click add cosmetics product
And I select notified in EU "No"
And I select are you likely to notify in EU "No"
Then I should be able to notify "post brexit" product "smoke test post-brexit manual notification"

