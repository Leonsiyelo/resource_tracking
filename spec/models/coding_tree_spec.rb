require File.dirname(__FILE__) + '/../spec_helper'

describe CodingTree do
  before :each do
    # Visual structure
    #
    #               / code111
    #      / code11 - code112
    # code1
    #      \ code12 - code121
    #               \ code122
    #
    #               / code211
    #      / code21 - code212
    # code2
    #      \ code22 - code221
    #               \ code222

    # first level
    @code1    = Factory.create(:code, :short_display => 'code1')
    @code2    = Factory.create(:code, :short_display => 'code2')

    # second level
    @code11    = Factory.create(:code, :short_display => 'code11')
    @code12    = Factory.create(:code, :short_display => 'code12')
    @code21    = Factory.create(:code, :short_display => 'code21')
    @code22    = Factory.create(:code, :short_display => 'code22')
    @code11.move_to_child_of(@code1)
    @code12.move_to_child_of(@code1)
    @code21.move_to_child_of(@code2)
    @code22.move_to_child_of(@code2)

    # third level
    @code111   = Factory.create(:code, :short_display => 'code111')
    @code112   = Factory.create(:code, :short_display => 'code112')
    @code121   = Factory.create(:code, :short_display => 'code121')
    @code122   = Factory.create(:code, :short_display => 'code122')
    @code211   = Factory.create(:code, :short_display => 'code211')
    @code212   = Factory.create(:code, :short_display => 'code212')
    @code221   = Factory.create(:code, :short_display => 'code221')
    @code222   = Factory.create(:code, :short_display => 'code222')
    @code111.move_to_child_of(@code11)
    @code112.move_to_child_of(@code11)
    @code121.move_to_child_of(@code12)
    @code122.move_to_child_of(@code12)
    @code211.move_to_child_of(@code21)
    @code212.move_to_child_of(@code22)
    @code221.move_to_child_of(@code22)
    @code222.move_to_child_of(@code22)

    @activity = Factory.create(:activity)

  end

  describe "Tree" do
    it "has code associated" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.roots.length.should == 1
      ct.roots[0].code.should == @code1
    end

    it "has code assignment associated" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.roots.length.should == 1
      ct.roots[0].ca.should == ca1
    end

    it "has children associated (children of root)" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.roots[0].children.length.should == 1
      ct.roots[0].children.map(&:ca).should == [ca11]
      ct.roots[0].children.map(&:code).should == [@code11]
    end

    it "has children associated (children of a children of a root)" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.roots[0].children[0].children.length.should == 1
      ct.roots[0].children[0].children.map(&:ca).should == [ca111]
      ct.roots[0].children[0].children.map(&:code).should == [@code111]
    end
  end

  describe "root" do
    it "has roots" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca2 = Factory.create(:coding_budget, :activity => @activity, :code => @code2)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.roots.length.should == 2
      ct.roots.map(&:ca).should   == [ca1, ca2]
      ct.roots.map(&:code).should == [@code1, @code2]
    end
  end

  describe "coding tree" do
    it "is valid when there are only roots" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca2 = Factory.create(:coding_budget, :activity => @activity, :code => @code2)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid?.should == true
    end

    it "is valid when sum_of_children is same as parent cached_sum (2 level)" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 100)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid?.should == true
    end

    it "is valid when sum_of_children is same as parent cached_sum (3 level)" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 100, :sum_of_children => 100)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111, :cached_amount => 100)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid?.should == true
    end

    it "is valid when root children has lower amount" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 99)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 99)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid?.should == true
    end

    it "is not valid when root children has greated amount" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 101)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 101)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid?.should == false
    end
  end

  describe "code assignment" do
    it "all code assignments are valid when coding tree is valid" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 100, :sum_of_children => 100)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111, :cached_amount => 100)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid_ca?(ca1).should == true
      ct.valid_ca?(ca11).should == true
      ct.valid_ca?(ca111).should == true
    end

    it "detects invalid node when coding tree is not valid" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 101)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 101)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.should_receive(:available_codes).and_return([@code1, @code2]) # stub available_codes
      ct.valid_ca?(ca1).should == false
      ct.valid_ca?(ca11).should == true
    end
  end

  # NOTE: these specs are done with stubing, but they need to be changed
  # to check for real objects once we remove codes seeds from test db
  describe "available_codes" do
    before :each do
      @fake_codes = [mock(:code)]
    end

    it "returns codes for simple activity and 'CodingBudget' type" do
      Code.stub_chain(:for_activities, :roots).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, CodingBudget)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for other cost activity and 'CodingBudget' type" do
      OtherCostCode.stub(:roots).and_return(@fake_codes)

      activity = Factory.create(:other_cost)
      ct       = CodingTree.new(activity, CodingBudget)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for simple activity and 'CodingBudgetCostCategorization' type" do
      CostCategory.stub(:roots).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, CodingBudgetCostCategorization)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for other cost activity and 'CodingBudgetCostCategorization' type" do
      CostCategory.stub(:roots).and_return(@fake_codes)

      activity = Factory.create(:other_cost)
      ct       = CodingTree.new(activity, CodingBudgetCostCategorization)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for simple activity and 'CodingBudgetDistrict' type" do
      activity = Factory.create(:activity)
      activity.stub(:locations).and_return(@fake_codes)

      ct       = CodingTree.new(activity, CodingBudgetDistrict)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for other cost activity and 'CodingBudgetDistrict' type" do
      activity = Factory.create(:other_cost)
      activity.stub(:locations).and_return(@fake_codes)

      ct       = CodingTree.new(activity, CodingBudgetDistrict)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for simple activity and 'HsspBudget' type" do
      HsspStratObj.stub(:all).and_return(@fake_codes)
      HsspStratProg.stub(:all).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, HsspBudget)
      ct.available_codes.should == @fake_codes.concat(@fake_codes)
    end

    it "returns codes for other cost activity and 'HsspBudget' type" do
      HsspStratObj.stub(:all).and_return(@fake_codes)
      HsspStratProg.stub(:all).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, HsspBudget)
      ct.available_codes.should == @fake_codes.concat(@fake_codes)
    end

    it "returns codes for simple activity and 'CodingSpend' type" do
      Code.stub_chain(:for_activities, :roots).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, CodingSpend)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for other cost activity and 'CodingSpend' type" do
      OtherCostCode.stub(:roots).and_return(@fake_codes)

      activity = Factory.create(:other_cost)
      ct       = CodingTree.new(activity, CodingSpend)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for simple activity and 'CodingSpendCostCategorization' type" do
      CostCategory.stub(:roots).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, CodingSpendCostCategorization)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for other cost activity and 'CodingSpendCostCategorization' type" do
      CostCategory.stub(:roots).and_return(@fake_codes)

      activity = Factory.create(:other_cost)
      ct       = CodingTree.new(activity, CodingSpendCostCategorization)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for simple activity and 'CodingSpendDistrict' type" do
      activity = Factory.create(:activity)
      activity.stub(:locations).and_return(@fake_codes)

      ct       = CodingTree.new(activity, CodingSpendDistrict)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for other cost activity and 'CodingSpendDistrict' type" do
      activity = Factory.create(:other_cost)
      activity.stub(:locations).and_return(@fake_codes)

      ct       = CodingTree.new(activity, CodingSpendDistrict)
      ct.available_codes.should == @fake_codes
    end

    it "returns codes for simple activity and 'HsspSpend' type" do
      HsspStratObj.stub(:all).and_return(@fake_codes)
      HsspStratProg.stub(:all).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, HsspSpend)
      ct.available_codes.should == @fake_codes.concat(@fake_codes)
    end

    it "returns codes for other cost activity and 'HsspSpend' type" do
      HsspStratObj.stub(:all).and_return(@fake_codes)
      HsspStratProg.stub(:all).and_return(@fake_codes)

      activity = Factory.create(:activity)
      ct       = CodingTree.new(activity, HsspSpend)
      ct.available_codes.should == @fake_codes.concat(@fake_codes)
    end
  end
end
