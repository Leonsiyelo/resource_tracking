require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "create" do
    before :each do
       @data_request = Factory.create(:data_request)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @response)
       login @user
     end
    
    it "redircts to the projects index page when save is clicked" do 
      post :create, :other_cost => {
        :description => "some description",
        :project_id => @project.id
      },
      :commit => 'Save', :response_id => @response.id
      response.should redirect_to(response_projects_url(@response.id))
    end
    
    it "redircts to the projects index page when Save & Go to Classify > is clicked" do 
      post :create, :other_cost => {
        :description => "some description",
        :project_id => @project.id
      },
      :commit => 'Save & Go to Classify >', :response_id => @response.id
      response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
    end
  end
end