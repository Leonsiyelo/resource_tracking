Feature: Reporter can see user guide upon login
  In order to train users
  As a reporter
  I want to be able to see user guide after logging in

@static_pages
Scenario: Login and see user guide
  Given a reporter "Frank" with email "frank@f.com" and password "password"
  When I go to the login page
  When I fill in "Username or Email" with "Frank"
  And I fill in "Password" with "password"
  And I press "Sign in"
  Then I should be on the help page
  Then I should see the reporters admin nav
  And I should see the main nav tabs
  And I should see "Using the Resource Tracking Tool"
  And I should see the common footer
  When I follow "Dashboard"
  
@static_pages
Scenario: Bug: should not see Projects/Implementers/etc tabs
  Given a reporter "Frank" with email "frank@f.com" and password "password"
  When I go to the login page
  When I fill in "Username or Email" with "Frank"
  And I fill in "Password" with "password"
  And I press "Sign in"
  Then I should be on the help page
  And I should see the main nav tabs
  And I should not see the data response tabs
