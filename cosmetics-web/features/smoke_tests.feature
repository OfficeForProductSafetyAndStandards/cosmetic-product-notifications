Feature: Smoke test

@smoke
Scenario: Login as business user
Given I login as business user 
Then I should be navigated to dashboard page

@smoke1
Scenario: notify pre-brexit product manually
Given I login as business user
When I click add cosmetics product
And I select Yes notified in EU
Then I should be able to notify product manually