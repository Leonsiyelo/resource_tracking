Feature: Manage organizations
  In order to have good organizations in the system
  As an admin
  I want to be able to manage organizations

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  
@admin_organizations
Scenario Outline: Merge duplicate organizations
  Given I am signed in as an admin
  When I go to the organizations page
  And I follow "Fix duplicate organizations"
  And I select "<duplicate>" from "Duplicate organization"
  And I select "<target>" from "Replacement organization"
  And I press "Replace"
  Then I should see "<message>"

  Examples:
    | duplicate | target             | message                                                  |
    | UNAIDS    | UNAIDS - 0 users   | Same organizations for duplicate and target selected.    |
    | UNAIDS    | WHO - 1 user       | Organizations successfully merged.                       |

@admin_organizations @javascript
Scenario Outline: Merge duplicate organizations (with JS)
  Given I am signed in as an admin
  When I go to the organizations page
  And I follow "Fix duplicate organizations"
  And I select "<duplicate>" from "Duplicate organization"
  And I should see "Organization: <duplicate_box>" within "#duplicate"
  And I select "<target>" from "Replacement organization"
  And I should see "Organization: <target_box>" within "#target"
  And I will confirm a js popup
  And I press "Replace"
  Then I should see "<message>"
  And the "Duplicate organization" text should be "<select_text>"

  Examples:
    | duplicate | target           | duplicate_box | target_box | message                                                  | select_text |
    | UNAIDS    | UNAIDS - 0 users | UNAIDS        | UNAIDS     | Same organizations for duplicate and target selected.    | UNAIDS      |
    | UNAIDS    | WHO - 1 user     | UNAIDS        | WHO        | Organizations successfully merged.                       |             |


@admin_organizations @javascript
Scenario Outline: Delete organization on merge duplicate organizations screen (with JS)
  Given I am signed in as an admin
  When I go to the organizations page
  And I follow "Fix duplicate organizations"
  And I select "<organization>" from "<select_type>"
  And I will confirm a js popup
  And I follow "Delete" within "<info_block>"
  Then the "Duplicate organization" text should not be "<organization>"
  Then the "Replacement organization" text should not be "<organization>"

  Examples:
    | organization     | select_type                 | info_block                  |
    | UNAIDS           | Duplicate organization      | .box[data-type='duplicate'] |
    | UNAIDS - 0 users | Replacement organization    | .box[data-type='target']    |

@admin_organizations @javascript
@run
Scenario: Try to delete non-empty organization (with JS)
  Given I am signed in as an admin
  When I go to the organizations page
  And I follow "Fix duplicate organizations"
  And I select "WHO - 1 user" from "Replacement organization"
  And I will confirm a js popup
  And I follow "Delete" within ".box[data-type='target']"
  # Check that WHO organization is not deleted
  Then the "Replacement organization" text should match "WHO - 1 user"
  And I should see "You cannot delete an organization that has users or data associated with it."
