Feature: NGO can see dashboard
  In order to ?
  As a NGO
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given I am on the ngo dashboard page
  Given I am signed in as a reporter
  Then I should see "Data Requests to Fulfill"

