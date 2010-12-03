require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do

  describe "basic validations" do
    subject { Factory(:data_response) }  
    it { should have_many(:projects) }
    it { should have_many(:activities) }
    it { should have_many(:funding_flows) }
    it { should belong_to(:responding_organization) }
    it { should belong_to(:data_request) }
    it { should validate_presence_of(:data_request_id) }
    it { should validate_presence_of(:organization_id_responder) }
    it { should validate_presence_of(:currency) } #on update
    it { should allow_value('2010-12-01').for(:fiscal_year_start_date) }
    it { should allow_value('2010-12-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('').for(:fiscal_year_start_date) }
    it { should_not allow_value('').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_end_date) }
  end

  describe "date validations" do
    it "accepts start date < end date" do
      dr = Factory.build(:data_response, 
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 02) )
      dr.should be_valid
    end

    it "does not accept start date > end date" do
      dr = Factory.build(:data_response, 
                         :fiscal_year_start_date => DateTime.new(2010, 01, 02),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

    it "does not accept start date = end date" do
      dr = Factory.build(:data_response, 
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end
  end 

  describe "on update" do
    it "validates currency is present" do
      dr = Factory.create(:data_response, 
                          :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                          :fiscal_year_end_date =>   DateTime.new(2010, 01, 02) )
      dr.currency = nil
      dr.save
      dr.should_not be_valid
      dr.errors.on(:currency).should_not be_nil
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:data_response)
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches projects count" do
      dr = Factory.create(:data_response)
      dr.projects_count.should == 0
      Factory.create(:project, :data_response => dr)
      dr.reload.projects_count.should == 1
      Factory.create(:project, :data_response => dr)
      dr.reload.projects_count.should == 2
    end

    it "caches activities count" do
      dr = Factory.create(:data_response)
      dr.activities_count.should == 0
      Factory.create(:activity, :data_response => dr)
      dr.reload.activities_count.should == 1
      Factory.create(:activity, :data_response => dr)
      dr.reload.activities_count.should == 2
    end

    it "caches sub activities count" do
      dr = Factory.create(:data_response)
      dr.sub_activities_count.should == 0
      Factory.create(:sub_activity, :data_response => dr)
      dr.reload.sub_activities_count.should == 1
      Factory.create(:sub_activity, :data_response => dr)
      dr.reload.sub_activities_count.should == 2
    end

    it "caches activities without projects count" do
      dr = Factory.create(:data_response)
      dr.activities_without_projects_count.should == 0
      Factory.create(:activity, :data_response => dr, :projects => [])
      dr.reload.activities_without_projects_count.should == 1
      Factory.create(:activity, :data_response => dr, :projects => [])
      dr.reload.activities_without_projects_count.should == 2
    end
  end
end
