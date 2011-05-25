Feature: Reporter can login
  In order to protect information
  As a reporter
  I want to be able to login
@leon1
Scenario: Leon attempting first feature leon trying to login
  Given a reporter exists with username: "Leon"
  And I go to the login page
  And I fill in "Username or Email" with "Leon"
  And I fill in "Password" with "password"
  When I press "Sign in"
  Then I should see the reporters admin nav
  And I should see the main nav tabs

@leon1
Scenario: Login as a reporter with email address
  Given a reporter exists with email: "leon@f.com"
  When I go to the login page
  And I fill in "Username or Email" with "leon@f.com"
  And I fill in "Password" with "password"
  And I press "Sign in"
  Then I should see the reporters admin nav
  And I should see "frank@f.com"
  And I should be on the reporter dashboard page
