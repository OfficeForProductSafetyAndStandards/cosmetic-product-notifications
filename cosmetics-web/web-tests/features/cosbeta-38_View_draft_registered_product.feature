Feature: View draft and registered product




@cosbeta-38 @regression
Scenario: View unfinished product
Given I login user as "rp_user"
When I click on "Show my cosmetic products"
Then I should see "Your cosmetic products"

@regression
Scenario: Verify unfinished tab show expected product
When I click on "Unfinished (3)"
Then I should see "Beautify Facial Night Cream"

@regression
Scenario: Verify registered tab shows expected product
When I click on "Registered (1)"
Then I should see "CTPA moisture conditioner"



