Feature: Validate phone number field in user registration form

@cosbeta-57 @regression
Scenario: Validate phone number field
Given I am on register field
And I enter all required fields
When I enter phone number field with invalid phone number "0788989898989809"
Then I should see error message "Invalid phone number"


Scenario: Validate phone number field
Given I am on register field
And I enter all required fields
When I enter phone number field with valid phone number ""
Then I should see error message "Invalid phone number"