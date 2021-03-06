Given /^a project$/ do
  @project = Factory(:project)
end

# You shouldn't create project records wihtout a DR/Org !!
#Given /^a project with name "([^\"]*)"$/ do |name|
#  @project = Factory(:project, :name => name)
#end

Given /^a project with name "([^"]*)" for request "([^"]*)" and organization "([^"]*)"$/ do |project_name, data_request_name, organization_name|
  @project = Factory(:project,
                    :name          => project_name,
                    :data_response => get_data_response(data_request_name, organization_name))
end

Given /^an implementer "([^"]*)" for project "([^"]*)"$/ do |implementer_name, project_name|
  steps %Q{
    Given an implementer "#{implementer_name}" who we gave "20000000" for project "#{project_name}"
  }
end

Given /^an implementer "([^"]*)" who we gave "([^"]*)" for project "([^"]*)"$/ do |implementer_name, budget, project_name|
  @project = Project.find_by_name(project_name)
  @implementer = Factory(:implementer,
                          :project       => @project,
                          :from          => @project.organization,
                          :budget        => budget,
                          :to            => Organization.find_by_name(implementer_name),
                          :data_response => @project.data_response)
end

Given /^an activity with name "([^\"]*)"$/ do |name|
  @activity = Factory(:activity, :name => name)
end

Given /^an activity with name "([^\"]*)" in project "([^\"]*)"$/ do |name, project|
  @activity = Factory(:activity,
                       :name => name,
                       :projects => [Project.find_by_name(project)])
end

Given /^an activity with name "([^"]*)" in project "([^"]*)", request "([^"]*)" and organization "([^"]*)"$/ do |activity_name, project_name, data_request_name, organization_name|
  @activity = Factory(:activity,
                       :name          => activity_name,
                       :data_response => get_data_response(data_request_name, organization_name),
                       :projects      => [Project.find_by_name(project_name)])

end

Given /^a budget coding for "([^"]*)" with amount "([^"]*)"$/ do |code_name, amount|
  # assumes @activity is set !
  @code_assignment = Factory(:coding_budget,
                             :activity => @activity,
                             :code => Code.find_by_short_display(code_name),
                             :amount => amount,
                             :cached_amount => amount)
  @activity.reload
end

# Uses "the activity" definition from Pickle
Given /^a budget coding code_name: "([^"]*)", activity: "([^"]*)", amount: "([^"]*)"$/ do |code_name, activity, amount|
  @code_assignment = Factory(:coding_budget,
                             :activity => model(activity),
                             :code => Code.find_by_short_display(code_name),
                             :amount => amount,
                             :cached_amount => amount)
end

Given /^#{capture_model} for code "([^"]*)" exists?(?: with #{capture_fields})?$/ do |name, code_name, fields|
  code_assignments = create_model(name, fields)
  code_assignments.merge(:code => Code.find_by_short_display(code_name))
end

Given /^the following projects$/ do |table|
  table.hashes.each do |hash|
    Factory(:project, { :data_response => get_data_response(hash.delete("request"),
                                                            hash.delete("organization"))
                      }.merge(hash) )
  end
end

Given /^the following comments$/ do |table|
  table.hashes.each do |hash|
    commentable = Project.find_by_name(hash.delete("project"))
    Factory(:comment, hash.merge(:commentable => commentable))
  end
end

Given /^a reporter "([^"]*)" with email "([^"]*)" and password "([^"]*)"$/ do | name, email, password|
@user = Factory(:reporter,
                :username              => name,
                :email                 => email,
                :password              => password,
                :password_confirmation => password)
end

Given /^an activity manager "([^"]*)" with email "([^"]*)" and password "([^"]*)"$/ do | name, email, password|
@user = Factory(:activity_manager,
                :username              => name,
                :email                 => email,
                :password              => password,
                :password_confirmation => password)
end

Given /^the following reporters$/ do |table|
  table.hashes.each do |hash|
    org  = Organization.find_by_name(hash.delete("organization"))
    username  = hash.delete("name")
    Factory(:reporter, { :username => username,
                         :organization => org
                       }.merge(hash) )
  end
end

Given /^the root codes$/ do |table|
  table.hashes.each do |hash|
    f = Factory(:root_code, hash.merge(:type => 'Nha'))
  end
end

Given /^the following activity managers$/ do |table|
  table.hashes.each do |hash|
    org  = Organization.find_by_name(hash.delete("organization"))
    username  = hash.delete("name")
    Factory(:activity_manager, { :username => username,
                                 :organization => org
                               }.merge(hash) )
  end
end


Given /^I am signed in as "([^"]*)"$/ do |name|
  steps %Q{
    When I go to the login page
    When I fill in "Username or Email" with "#{name}"
    And  I fill in "Password" with "password"
    And  I press "Sign in"
  }
end

Given /^I am signed in as a reporter$/ do
  steps %Q{
    Given a reporter "Frank" in organization "Test Org"
    Given I am signed in as "Frank"
  }
end

Given /^I am signed in as an activity manager$/ do
  steps %Q{
    Given an activity manager "Frank" in organization "Test Org"
    Given I am signed in as "Frank"
  }
end

Given /^I am signed in as an admin$/ do
  steps %Q{
    Given an admin "Frank" in organization "Test Org"
    Given I am signed in as "Frank"
  }
end

Given /^an organization with name "([^"]*)"$/ do |name|
  @organization = Factory(:organization, :name => name)
end

Given /^a data request with title "([^\"]*)" from "([^\"]*)"$/ do |title, requestor|
  org  = Organization.find_by_name(requestor)
  @data_request = Factory(:data_request,
                          :title                   => title,
                          :requesting_organization => org)

end

Given /^the following organizations$/ do |table|
  table.hashes.each do |hash|
    Factory(:organization, hash)
  end
end

Given /^a reporter "([^"]*)" in organization "([^"]*)"$/ do |name, org_name|
  @organization = Factory(:organization, :name => org_name)
  @user = Factory(:reporter,
                  :username => name,
                  :email => 'frank@f.com',
                  :password => 'password',
                  :password_confirmation => 'password',
                  :organization => @organization)
end

Given /^an activity manager "([^"]*)" in organization "([^"]*)"$/ do |name, org_name|
  @organization = Factory(:organization, :name => org_name)
  @user = Factory(:activity_manager,
                  :username              => name,
                  :email                 => 'frank@f.com',
                  :password              => 'password',
                  :password_confirmation => 'password',
                  :organization          => @organization)

end

Given /^an admin "([^"]*)" in organization "([^"]*)"$/ do |name, org_name|
  @organization = Factory(:organization, :name => org_name)
  @user = Factory(:admin,
                  :username              => name,
                  :email                 => 'frank@f.com',
                  :password              => 'password',
                  :password_confirmation => 'password',
                  :organization          => @organization)

end

Given /^the following funding flows$/ do |table|
  table.hashes.each do |hash|
    to_org   = Organization.find_by_name(hash.delete("to"))
    project  = Project.find_by_name(hash.delete("project"))
    from_org = Organization.find_by_name(hash.delete("from"))
    Factory(:funding_flow, {
                            :project       => project,
                            :to            => to_org.id,
                            :from          => from_org,
                            :data_response => project.data_response
                          }.merge(hash) )
  end
end

Then /^debug$/ do
  debugger
end

Then /^I should see the "([^"]*)" tab is active$/ do |text|
  steps %Q{
    Then I should see "#{text}" within "li.selected"
  }
end

Then /^I should see the visitors header$/ do
  steps %Q{
    Then I should see "Have an account?" within "div#admin"
    And I should see "Sign in" within "div#admin"
  }
end

Then /^I should see the reporters admin nav$/ do
  steps %Q{
    Then I should see "My Profile" within "div#admin"
    Then I should see "Sign Out" within "div#admin"
  }
end

Then /^I should see the common footer$/ do
  steps %Q{
    Then I should see "About" within "div#footer"
    Then I should see "Help" within "div#footer"
    Then I should see "Contact Us" within "div#footer"
    Then I should see "News" within "div#footer"
  }
end

Then /^I should see the main nav tabs$/ do
  steps %Q{
    Then I should see "Dashboard" within "div#main-nav"
    Then I should see "My Data" within "div#main-nav"
    Then I should see "Reports" within "div#main-nav"
    Then I should see "Help" within "div#main-nav"
  }
end

Then /^I should see the data response tabs$/ do
  steps %Q{
    Then I should see "Projects" within "li"
  }
end

Then /^I should not see the data response tabs$/ do
  steps %Q{
    Then I should not see "Projects" within "li"
  }
end

# use this when you need to match the EXACT value of a field (vs the "should contain" matcher)
Then /^the "([^"]*)" field(?: within "([^"]*)")? should equal "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should == value
    else
      assert_equal(value, field_value)
    end
  end
end

# a bit brittle
When /^I fill in the percentage for "Human Resources For Health" with "([^"]*)"$/ do |amount|
  steps %Q{ When I fill in "activity_updates_1_percentage" with "#{amount}"}
end

Then /^the percentage for "Human Resources For Health" field should equal "([^"]*)"$/ do |amount|
  steps %Q{ Then the "activity_updates_1_percentage" field should equal "#{amount}"}
end


# band aid fix
Given /^a data response to "([^"]*)" by "([^"]*)"$/ do |request, org|
  @data_response = Factory(:data_response,
                            :data_request => DataRequest.find_by_title(request),
                            :organization => Organization.find_by_name(org))
end

Then /^wait a few moments$/ do
  sleep 4
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_css?("#{selector}", :visible => true)
end

Given /^a basic org \+ reporter profile, with data response, signed in$/ do
  steps %Q{
    Given an organization exists with name: "GoR"
    And a data_request exists with title: "Req1"
    And an organization exists with name: "UNDP"
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with username: "undp_user", organization: the organization, current_data_response: the data_response
    And a project exists with name: "TB Treatment Project", data_response: the data_response
    And an activity exists with name: "TB Drugs procurement", data_response: the data_response
    And the project is one of the activity's projects
    And I am signed in as "undp_user"
  }
end

Given /^organizations, reporters, data request, data responses, projects$/ do
  steps %Q{
    Given the following organizations
      | name   |
      | UNDP   |
      | USAID  |
      | GoR    |
    Given the following reporters
       | name         | organization |
       | undp_user    | UNDP         |
    Given a data request with title "Req1" from "GoR"
    Given a data response to "Req1" by "UNDP"
    Given a data response to "Req1" by "USAID"
    Given the following projects
      | name                 | request | organization |
      | TB Treatment Project | Req1    | UNDP         |
      | Other Project        | Req1    | USAID        |
    Given an activity with name "TB Drugs procurement" in project "TB Treatment Project", request "Req1" and organization "UNDP"
  }
end

Given /^a model help for "([^"]*)"$/ do |model_name|
  Factory(:model_help, :model_name => model_name)
end

Given /^model help for "([^"]*)" page$/ do |page|
  model_help_name = case page
                    when 'projects'
                      "Project"
                    when 'funding sources'
                      "FundingSource"
                    when 'implementers'
                      "Provider"
                    when 'activities'
                      "Activity"
                    when 'classifications'
                      "CodeAssignment"
                    when 'other costs'
                      "OtherCost"
                    when 'review'
                      "DataResponseReview"
                    end
  steps %Q{
    Given a model help for "#{model_help_name}"
  }
end

Given /^location "([^"]*)" for activity "([^"]*)"$/ do |location_name, activity_name|
  activity = Activity.find_by_name(activity_name)
  location = Location.find_by_short_display(location_name)
  activity.locations << location
end

Then /^I can manage the comments$/ do
  steps %Q{
    When I click element "#project_details"
    And I click element "#projects .project .descr"
    And I click element "#projects .activity_details"
    And I click element "#projects .activity .descr"
    And I click element "#projects .activity .comment_details"
    And I follow "+ Add Comment" within ".activity"
    And I fill in "Title" with "comment title"
    And I fill in "Comment" with "comment body"
    And I press "Create comment"
    Then I should see "comment title"
    And I should see "comment body"
    When I follow "Edit" within "#projects .activity .resources"
    And I fill in "Title" with "new comment title"
    And I fill in "Comment" with "new comment body"
    And I press "Update comment"
    Then I should see "new comment title"
    And I should see "new comment body"
    When I confirm the popup dialog
    And I follow "Delete" within "#projects .activity .resources"
    Then I should not see "new comment title"
    And I should not see "new comment body"
  }
end

Then /^I should see tabs for comments,projects,non-project activites$/ do
  steps %Q{
    Then I should see "Comments" within the selected data response sub-tab
    When I click element "#data_response_sub_tabs ul li a#project_details"
    Then I should see "Projects" within the selected data response sub-tab
    When I click element "#data_response_sub_tabs ul li a.activity_details"
    Then I should see "Activities without a Project" within the selected data response sub-tab
    When I click element "#data_response_sub_tabs ul li a.comment_details"
    Then I should see "Comments" within the selected data response sub-tab
  }
end

Then /^I should see tabs for comments,activities,other costs$/ do
  steps %Q{
    When I click element "#data_response_sub_tabs > ul:first-child li a#project_details"
    And I click element ".project .descr"
    Then I should see "Comments" within the selected project sub-tab
    When I click element ".project_sub_tabs ul li a.activity_details"
    Then I should see "Activities" within the selected project sub-tab
    When I click element ".project_sub_tabs ul li:last a.activity_details"
    Then I should see "Other Costs" within the selected project sub-tab
    When I click element ".project_sub_tabs ul li a.comment_details"
    Then I should see "Comments" within the selected project sub-tab
  }
end

Then /^I should see tabs for comments,sub-activities when activities already open$/ do
  steps %Q{
    When I click element "#data_response_sub_tabs > ul:first-child li a#project_details"
    And I click element ".project_sub_tabs ul li a.activity_details"
    And I click element ".activities .activity.entry_header"
    Then I should see "Comments" within the selected activity sub-tab
    When I click element ".activity_sub_tabs ul li:last a"
    Then I should see "Sub-Activities" within the selected activity sub-tab
    When I click element ".activity_sub_tabs ul li:first"
    Then I should see "Comments" within the selected activity sub-tab
  }
end

Then /^I should see tabs for comments,sub-activities$/ do
  steps %Q{
    When I click element "#data_response_sub_tabs > ul:first-child li a#project_details"
    And I click element ".project .descr"
    And I click element ".project_sub_tabs ul li a.activity_details"
    And I click element ".activities .activity.entry_header"
    Then I should see "Comments" within the selected activity sub-tab
    When I click element ".activity_sub_tabs ul li:last a"
    Then I should see "Sub-Activities" within the selected activity sub-tab
    When I click element ".activity_sub_tabs ul li:first"
    Then I should see "Comments" within the selected activity sub-tab
  }
end

Given /^"([^"]*)" and "([^"]*)" are fake Mtef roots$/ do |arg1, arg2|
  code1 = Code.find_by_short_display(arg1)
  code2 = Code.find_by_short_display(arg2)
  Mtef.stub!(:roots).and_return([code1, code2])
end
